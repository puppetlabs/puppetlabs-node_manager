class node_manager::install(
  $version  = $node_manager::params::version,
)
inherits node_manager::params{
$do_noop     = $node_manager::params::do_noop
package { 'puppetclassify':
      ensure   => $version,
      provider => 'puppet_gem',
      noop     => $do_noop,  
  }
}
