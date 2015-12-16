class node_manager::puppetclassify::install(
  $version = $node_manager::params::version
) inherits node_manager::params {
$gemprovider = $node_manager::params::gemprovider

  package { 'puppetclassify':
    ensure => present,
    provider  => $gemprovider,
  }
}

}
