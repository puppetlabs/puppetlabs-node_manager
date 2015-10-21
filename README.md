
#node_manager

####Table of Contents
1. [Overview](#overview)
1. [Requirements] (#requirements)
1. [Types] (#types)
  * [Node_group] (#node_group)
  * [Puppet_environment] (#puppet_environment)

## Overview

Create and manage Node Manager API endpoints as resources.

## Module State

NOTE: This module is a Professional Service side project and is currently unmaintained. 
It is not supported and may not function as expected.

## Requirements:

- *nix operating system
- Puppet >= 3.7.1  
- [puppetclassify](https://github.com/puppetlabs/puppet-classify) gem

## Types

### Node_group

Node_groups will autorequire parent node_groups.

Enumerate all node groups:
* `puppet resource node_group`<br />

Example output for `puppet resource node_group 'PE MCollective'`
```
node_group { 'PE MCollective':
  ensure               => 'present',
  classes              => {'puppet_enterprise::profile::mcollective::agent' => {}},
  environment          => 'production',
  id                   => '4cdec347-20c6-46d7-9658-7189c1537ae9',
  override_environment => 'false',
  parent               => 'PE Infrastructure',
  rule                 => ['and', ['~', ['fact', 'pe_version'], '.+']],
}
```

### Node_group parameters

* `classes`<br />
Classes that are assigned to the node in hash format.  Elements of the hash
are class parameters. Default (empty hash): `{}`

* `environment`<br />
Environment selected for this node group. Default: `production`

* `name`<br />
(namevar) Node group's name.

* `id`<br />
Universal ID for the group. This attribute is read-only.

* `override_environment`<br />
Whether or not this group's environment ment setting overrides
all other other environments. Default: `false`

* `parent`<br />
The UID for the data group. Can be specified by group name or
UID. Default: `default`

* `rules`<br />
An array of classification rules. Default (empty hash): `{}`

### Puppet_environment

Enumerate all puppet environments:
* `puppet resource puppet_environment`<br />

Example output for `puppet resource puppet_environment production`
```
puppet_environment { 'production':
  ensure => 'present',
}
```
### Puppet_environment parameters

* `name`<br />
(namevar) Name of the Puppet environment on disk, i.e. the directory name in `$environmentpath`.
