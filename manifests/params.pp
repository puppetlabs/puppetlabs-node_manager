class node_manager::params{
$version = '0.1.0'

# puppetversion deprecated in 2015.2 in favour of pe_server_version
  if $puppetversion >= '3.8.0' { 
    $do_noop = false
  }
  elsif  $pe_server_version == '2015.2.0' {
    $do_noop = false
  }
  else{
    $do_noop = true
  }
}
