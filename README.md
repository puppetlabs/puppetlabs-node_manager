# node_manager [![Build Status](https://travis-ci.org/WhatsARanjit/prosvcs-node_manager.svg)](https://travis-ci.org/WhatsARanjit/prosvcs-node_manager)

#### Table of Contents

1. [Overview](#overview)
1. [Requirements](#requirements)
1. [Authentication](#authentication)
1. [Types](#types)
    * [Node_group](#node_group)
    * [Puppet_environment](#puppet_environment)
1. [Functions](#functions)
    * [node_groups()](#node_groups)
1. [Things to do](#things-to-do)

## Overview

Create and manage PE node groups as resources.

## Requirements

* \*nix operating system
* Puppet >= 3.7.1
* [puppetclassify](https://github.com/puppetlabs/puppet-classify) gem
* [puppetlabs/pe_gem module](https://forge.puppetlabs.com/puppetlabs/pe_gem)
* NOTE: new `https` provider which doesn't need gem dependency at [HTTPS.md](HTTPS.md)

## Classes

### Node_manager

The node_manager class facilitates the deployment of the puppetclassify gem
simply include node_manager in your node definition or add it to the pe_master node group

## Authentication

### PE Console server

Using the types and functions on the PE Console server will read the configuration at
`/etc/puppetlabs/puppet/classifier.yaml` which contains the default server information
and SSL certificate paths.  No extra configuration is necessary.

### Remote client or custom information

In order to manage node groups from a remote client, you'll need to [whitelist a certificate](https://docs.puppet.com/pe/latest/nc_forming_requests.html#whitelisted-certificate)
or [generate a token](https://docs.puppet.com/pe/latest/nc_forming_requests.html#authentication-token) with permissions to edit node groups.
Create a file at `/etc/puppetlabs/puppet/node_manager.yaml` in the following format:

```
server: master.puppetlabs.vm             # Defaults to $settings::server
port: 4433                               # Defaults to 4433
# Supply certs
hostcert: /root/certs/client.pem
hostprivkey: /root/certs/client_key.pem
localcacert: /root/certs/ca.pem
# Or token
token: AJLqDQxalbVSMWrZcX03aGtixvk_S2xGZfQizY9YvzVk
```

_NOTE:_ The token will be favored if both SSL and a token is provided.

## Types

### Node_group

Node_groups will autorequire parent node_groups.

Enumerate all node groups:

* `puppet resource node_group`

Example output for `puppet resource node_group 'PE MCollective'`

```puppet
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

#### Node_group parameters

* `description`

  Description of the node_group.

* `classes`

  Classes that are assigned to the node in hash format. Elements of the hash are class parameters.

  Default (empty hash): `{}`

* `environment`

  Environment selected for this node group.

  Default: `production`

* `name`

  (namevar) Node group's name.

* `id`

  Universal ID for the group. This attribute is read-only.

* `override_environment`

  Whether or not this group's environment ment setting overrides all other other environments.

  Default: `false`

* `parent`

  The UID for the data group. Can be specified by group name or UID.

  Default: `default`

* `rules`

  An array of classification rules.

  Default (empty array): `[]`

### Puppet_environment

Enumerate all puppet environments:

* `puppet resource puppet_environment`

Example output for `puppet resource puppet_environment production`

```puppet
puppet_environment { 'production':
  ensure => 'present',
}
```

#### Puppet_environment parameters

* `name`

  (namevar) Name of the Puppet environment on disk, i.e. the directory name in `$environmentpath`.

## Functions

### node_groups()

Retrieve all or one node_group and its data.

`node_groups()` will return:

```puppet
{
  "default"=>{
    "environment_trumps"=>false,
    "parent"=>"00000000-0000-4000-8000-000000000000",
    "name"=>"default",
    "rule"=>["and", ["~", "name", ".*"]],
    "variables"=>{}, "id"=>"00000000-0000-4000-8000-000000000000",
    "environment"=>"production",
    "classes"=>{}
  },
  "Production environment"=>{
    "environment_trumps"=>false,
    "parent"=>"00000000-0000-4000-8000-000000000000",
    "name"=>"Production environment",
    "rule"=>["and", ["~", "name", ".*"]],
    "variables"=>{},
    "id"=>"7233f964-951e-4a7f-88ea-72676ed3104d",
    "environment"=>"production",
    "classes"=>{}
  },
  ...
}
```

`node_groups('default')` will return:

```puppet
{
  "default"=>{
    "environment_trumps"=>false,
    "parent"=>"00000000-0000-4000-8000-000000000000",
    "name"=>"default",
    "rule"=>["and", ["~", "name", ".*"]],
    "variables"=>{}, "id"=>"00000000-0000-4000-8000-000000000000",
    "environment"=>"production",
    "classes"=>{}
  }
}
  ```

_Type:_ rvalue

## Things to do

* Remove `puppetclassify` dependency
* Get feedback on `https` provider, new [HTTPS.md](HTTPS.md)

## Maintainers

This repositority is largely the work of some Puppet community members.
It is not officially maintained by Puppet, or any individual in
particular. Issues should be opened in Github. Questions should be directed
at the individuals responsible for committing that particular code.
