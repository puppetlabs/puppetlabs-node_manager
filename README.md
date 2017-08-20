# node_manager [![Build Status](https://travis-ci.org/WhatsARanjit/prosvcs-node_manager.svg)](https://travis-ci.org/WhatsARanjit/prosvcs-node_manager)

#### Table of Contents

1. [Overview](#overview)
1. [Requirements](#requirements)
1. [Authentication](#authentication)
1. [Types](#types)
    * [Node_group](#node_group)
1. [Functions](#functions)
    * [node_groups()](#node_groups)
1. [Face](#face)
1. [Things to do](#things-to-do)
1. [Experimental](#experimental)

## Overview

Create and manage PE node groups as resources.

## Requirements

* \*nix operating system
* Puppet >= 3.7.1
* New `https` provider which doesn't need `puppetclassify` gem

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

  Default: `All Nodes`

* `rules`

  An array of classification rules.  To submit an empty ruleset, use `''` as your value.

  Default (empty array): `[]`

## Functions

### node_groups()

Retrieve all or one node_group and its data.

`node_groups()` will return:

```puppet
{
  "All Nodes"=>{
    "environment_trumps"=>false,
    "parent"=>"00000000-0000-4000-8000-000000000000",
    "name"=>"All Nodes",
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

`node_groups('All Nodes')` will return:

```puppet
{
  "All Nodes"=>{
    "environment_trumps"=>false,
    "parent"=>"00000000-0000-4000-8000-000000000000",
    "name"=>"All Nodes",
    "rule"=>["and", ["~", "name", ".*"]],
    "variables"=>{}, "id"=>"00000000-0000-4000-8000-000000000000",
    "environment"=>"production",
    "classes"=>{}
  }
}
  ```

_Type:_ rvalue

## Face

The `node_manager` face allows you to interact with endpoints other than
the groups endpoint using the type or function. Use the `--help` flag
to explore functionaliy of each action.

```
# puppet node_manager --help

USAGE: puppet node_manager <action>

Interact with node classifier API

OPTIONS:
  --render-as FORMAT             - The rendering format to use.
  --verbose                      - Whether to log verbosely.
  --debug                        - Whether to log debug information.

ACTIONS:
  classes         List class information
  classified      List classification information
  environments    Query environment sync status
  groups          List group information
  unpin           Unpin a node from all groups

See 'puppet man node_manager' or 'man puppet-node_manager' for full help.
```

## Things to do

* Nothing at the moment

## Experimental

New puppet-less provider with bash [here](scripts/README.md)

## Maintainers

This repositority is largely the work of some Puppet community members.
It is not officially maintained by Puppet, or any individual in
particular. Issues should be opened in Github. Questions should be directed
at the individuals responsible for committing that particular code.
