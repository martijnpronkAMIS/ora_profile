# ora_profile::database::asm_storage::nfs
#
# Configure NFS storage
#
# @summary A short summary of the purpose of this class
#
# @example
#   include ora_profile::database::asm_storage::nfs
class ora_profile::database::asm_storage::nfs(
  String[1] $grid_user,
  String[1] $grid_admingroup,
  Array[Stdlib::Absolutepath]
            $nfs_files,
  Stdlib::Absolutepath
            $nfs_mountpoint,
  Stdlib::Absolutepath
            $nfs_export,
  String[1] $nfs_server,
)
{

  file { $nfs_export:
    ensure  => directory,
    recurse => false,
    replace => false,
    mode    => '0775',
    owner   => $grid_user,
    group   => $grid_admingroup,
  }

  $nfs_files.each |$file| {
    exec { "/bin/dd if=/dev/zero of=${file} bs=1 count=0 seek=7520M":
      user      => $grid_user,
      group     => $grid_admingroup,
      logoutput => true,
      unless    => "/usr/bin/test -f ${file}",
    }

    -> file { $file:
      ensure => present,
      owner  => $grid_user,
      group  => $grid_admingroup,
      mode   => '0664',
    }
  }

  contain ::nfs

  nfs::server::export{ $nfs_export:
    ensure      => 'mounted',
    options_nfs => 'rw sync no_wdelay insecure_locks no_root_squash',
    clients     => '192.168.253.0/24(rw,insecure,async,no_root_squash) localhost(rw)',
  }

  -> file { $nfs_mountpoint:
    ensure  => directory,
    recurse => false,
    replace => false,
    mode    => '0775',
    owner   => $grid_user,
    group   => $grid_admingroup,
  }

  -> nfs::client::mount { $nfs_mountpoint:
    server      => $nfs_server,
    share       => $nfs_export,
    remounts    => true,
    atboot      => true,
    nfs_v4      => false,
    options_nfs => '_netdev,rw,bg,hard,nointr,rsize=65536,wsize=65536,tcp,timeo=600,noatime',
    # before      => Class['ora_profile::database::asm_software'],
  }
}
