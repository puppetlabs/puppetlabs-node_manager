class node_manager::params{
  $version = '0.1.2'
  if $puppetversion =~ /3.8/ {
    $provider='pe_gem'
  }
  elsif $pe_server_version >= '2015.0' {
    $provider ='puppet_gem'
  }
  else {
    $provider ='gem'
  }

}

