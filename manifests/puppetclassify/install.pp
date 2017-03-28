class node_manager::puppetclassify::install (
  $version     = $node_manager::params::version,
  $gemprovider = $node_manager::params::gemprovider
) inherits node_manager::params {

  package { 'puppetclassify':
    ensure   => $version,
    provider => $gemprovider,

  }
}


