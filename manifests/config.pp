# @summary Configure authselect
#
# @example
#   include authselect::config
class authselect::config {
  assert_private()
  $current_features = $facts['authselect_profile_features'].lest || { [] }.sort
  $requested_features = $authselect::profile_options.sort
  $requested_features_string = $requested_features.join(' ')

  if $current_features.join(' ') != $requested_features_string or $facts['authselect_profile'] != $authselect::profile {
    exec { "authselect set profile=${authselect::profile} features=${requested_features}":
      path    => ['/usr/bin', '/usr/sbin',],
      command => "authselect select ${authselect::profile} ${requested_features_string} --force",
    }
  } else {
    exec { "authselect set profile=${authselect::profile} features=${requested_features}":
      path    => ['/usr/bin', '/usr/sbin',],
      command => "authselect select ${authselect::profile} ${requested_features_string} --force",
      unless  => 'authselect check',
      notify  => Exec['authselect apply-changes'],
    }
  }

  exec { 'authselect apply-changes':
    path        => ['/usr/bin', '/usr/sbin',],
    refreshonly => true,
  }
}
