Run this through puppet apply to re-create PE groups.  Replace 'master.puppetlabs.vm' with your master hostname as well as any other ports configs, etc.
```
node_group { 'PE ActiveMQ Broker':
  ensure               => 'present',
  classes              => {'puppet_enterprise::profile::amq::broker' => {}},
  environment          => 'production',
  override_environment => false,
  parent               => 'PE Infrastructure',
  rule                 => ['or', ['=', 'name', 'master.puppetlabs.vm']],
}
node_group { 'PE Certificate Authority':
  ensure               => 'present',
  classes              => {'puppet_enterprise::profile::certificate_authority' => {}},
  environment          => 'production',
  override_environment => false,
  parent               => 'PE Infrastructure',
  rule                 => ['or', ['=', 'name', 'master.puppetlabs.vm']],
}
node_group { 'PE Console':
  ensure               => 'present',
  classes              => {'pe_console_prune' => {'prune_upto' => '30'}, 'puppet_enterprise::license' => {}, 'puppet_enterprise::profile::console' => {}, 'puppet_enterprise::profile::mcollective::console' => {}},
  environment          => 'production',
  override_environment => false,
  parent               => 'PE Infrastructure',
  rule                 => ['or', ['=', 'name', 'master.puppetlabs.vm']],
}
node_group { 'PE Infrastructure':
  ensure               => 'present',
  classes              => {'puppet_enterprise' => {'certificate_authority_host' => 'master.puppetlabs.vm', 'console_host' => 'master.puppetlabs.vm', 'console_port' => '443', 'database_host' => 'master.puppetlabs.vm', 'database_port' => '5432', 'database_ssl' => 'true', 'mcollective_middleware_hosts' => ['master.puppetlabs.vm'], 'puppet_master_host' => 'master.puppetlabs.vm', 'puppetdb_database_name' => 'pe-puppetdb', 'puppetdb_database_user' => 'pe-puppetdb', 'puppetdb_host' => 'master.puppetlabs.vm', 'puppetdb_port' => '8081'}},
  environment          => 'production',
  override_environment => false,
  parent               => 'default',
}
node_group { 'PE MCollective':
  ensure               => 'present',
  classes              => {'puppet_enterprise::profile::mcollective::agent' => {}},
  environment          => 'production',
  override_environment => false,
  parent               => 'PE Infrastructure',
  rule                 => ['and', ['~', ['fact', 'pe_version'], '.+']],
}
node_group { 'PE Master':
  ensure               => 'present',
  classes              => {'pe_repo' => {}, 'pe_repo::platform::el_6_x86_64' => {}, 'puppet_enterprise::profile::master' => {}, 'puppet_enterprise::profile::master::mcollective' => {}, 'puppet_enterprise::profile::mcollective::peadmin' => {}},
  environment          => 'production',
  override_environment => false,
  parent               => 'PE Infrastructure',
  rule                 => ['or', ['=', 'name', 'master.puppetlabs.vm']],
}
node_group { 'PE PuppetDB':
  ensure               => 'present',
  classes              => {'puppet_enterprise::profile::puppetdb' => {}},
  environment          => 'production',
  override_environment => false,
  parent               => 'PE Infrastructure',
  rule                 => ['or', ['=', 'name', 'master.puppetlabs.vm']],
}
```
