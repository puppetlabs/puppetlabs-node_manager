class node_manager (
  $warn = true,
) {

  require node_manager::puppetclassify::install

  if $warn {
    notify { 'This class is deprecated':
      message  => 'HTTPS provider no longer needs puppetclassify gem.',
      loglevel => 'warning',
    }
  }
}
