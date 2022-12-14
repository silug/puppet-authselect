# @summary Manage authselect's active profile
#
# This will select the requested authselect profile
#
# @param package_manage
#   Should this class manage the authselect package(s)
# @param package_ensure
#   Passed to `package` `ensure` for the authselect package(s)
# @param package_names
#   Packages to manage in this class
# @param profile_manage
#   Should this class set the active profile
# @param profile
#   Which authselect profile should be used
# @param profile_options
#   What options should we pass to authselect
#   ie, what features should be enabled/disabled?
# @param custom_profiles
#   Custom profiles to manage
class authselect (
  Boolean $package_manage,
  String  $package_ensure,
  Array[String[1], 1] $package_names,

  Boolean $profile_manage,
  String[1] $profile,
  Array[String, 0] $profile_options,
  Hash $custom_profiles,
) {
  if $package_manage {
    include 'authselect::package'
  }

  if $profile_manage and $package_ensure != 'absent' {
    include 'authselect::config'
  }

  $custom_profiles.each |$key, $value| {
    authselect::custom_profile { $key:
      * => $value,
    }
  }
}
