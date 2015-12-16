class node_manager::params{
  $version = '0.1.2'
  if $puppetversion =~ /3.8/ {
    $gemprovider='pe_gem'
  }
  elsif $pe_server_version >= '2015.0' {
    $gemprovider ='puppet_gem'
  }
  else {
    $gemprovider ='gem'
  }

}

