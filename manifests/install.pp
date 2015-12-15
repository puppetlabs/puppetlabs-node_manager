class node_manager::install(
  $version = $node_manager::params::version
) inherits node_manager::params {
$install = $node_manager::params::install
if $install{
  package { 'puppetclassifier':
    ensure => present,
    provider  => 'puppet_gem',

  }
}
else{
  Notify{'This class may not be required with your PE version':}
}

}
