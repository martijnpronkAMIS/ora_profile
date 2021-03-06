#++--++
#
# ora_profile::db_profiles
#
# @summary This class contains the definition for all Oracle profiles you'd like on your system.
# When these customizations aren't enough, you can replace the class with your own class. See [ora_profile::database](./database.html) for an explanation on how to do this.
#
# @param [Hash] list
#    A list of database profiles to define.
#    The default value is: {}
#    This is a simple way to get started, but soon your hiera yaml will become a nightmare. Our advice is that when you need to let Puppet manage your Oracle profiles, to override this class and add your own Puppet implementation. This is a much better solution because it is maintainable and more consistency.
#
#--++--
class ora_profile::database::db_profiles(
  Hash $list,
) inherits ora_profile::database {

  if $list.keys.size > 0 {
    echo {"Ensure DB profile(s) ${list.keys.join(',')}":
      withpath => false,
    }
  }
  #
  # This is a simple way to get started. It is easy to get started, but
  # soon your hiera yaml become a nigtmare. Our advise is when you need
  # to let puppet manage your Oracle profiles, to override this class and 
  # add your own puppet implementation. This is much better maintainable
  # and adds more consistency,
  #
  ensure_resources(ora_profile, $list)
}
