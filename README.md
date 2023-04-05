# node_manager [![Build Status](https://app.travis-ci.com/WhatsARanjit/puppet-node_manager.svg?branch=master)](https://app.travis-ci.com/WhatsARanjit/puppet-node_manager)

#### Table of Contents

1. [Overview](#overview)
1. [Requirements](#requirements)
1. [Authentication](#authentication)
1. [Types](#types)
    * [Node_group](#node_group)
1. [Tasks](#tasks)
    * [update_classes](#update_classes)
1. [Functions](#functions)
    * [node_groups()](#node_groups)
    * [get_nodes()](#get_nodes)
1. [Face](#face)
1. [Things to do](#things-to-do)
1. [Experimental](#experimental)

## Overview

Create and manage PE node groups as resources.

## Requirements

* \*nix operating system
* Puppet >= 3.7.1
* New `https` provider which doesn't need `puppetclassify` gem

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

* `variables`

  Global variables for the node group expressed in a hash as `{ 'var' => 'value' }`.

  Default (empty hash): `{}`

* `data`

  Configuration data supplied for automatic parameter lookup for the group. 
Data for the node group expressed in a hash as `{ 'class' => { 'param' => 'value' }}`.
This parameter is supported for PE >=2017.3.x.

  Default (empty hash): `{}`

* `purge_behavior`

  Defines how purging of classification, data and rules will be handled. By default, or when set to `all`, the node\_group resource will ensure classes, data and rules are matched exactly, and remove any values not described by the resource. When set to `none`, the node\_group resource will ensure data, classes and rules described are present with the prescribed values, but will not remove other classification, or other data, present in the node group. The `data` setting purges only data values, the `classes` setting purges only classes values and the `rule` setting purges only rule values. In case of conflict with the node classifiers `Nodes must match all rules.` and `Nodes may match any rule.` radio buttons. The node classifier takes precedence over defined node_group code.

  Default: `all`

  Values: `all`, `data`, `classes`, `rule`, `none`

## Tasks

### update_classes

Trigger update-classes job

```shell
puppet task run node_manager::update_classes --nodes 'pe-master' environment=production

```

__NOTE__: Default environment value is `production`.

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
    "classes"=>{},
    "config_data"=>{}
  },
  "Production environment"=>{
    "environment_trumps"=>false,
    "parent"=>"00000000-0000-4000-8000-000000000000",
    "name"=>"Production environment",
    "rule"=>["and", ["~", "name", ".*"]],
    "variables"=>{},
    "id"=>"7233f964-951e-4a7f-88ea-72676ed3104d",
    "environment"=>"production",
    "classes"=>{},
    "config_data"=>{}
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
    "classes"=>{},
    "config_data"=>{}
  }
}
  ```

_Type:_ rvalue

### get_nodes()

Retrieve historical info about a node's check-ins and classification, if check-in storage is enabled.

`get_nodes(nodename)` will return:

```puppet
{
  "name": "Deep Space 9",
  "check_ins": [
    {
      "time": "2369-01-04T03:00:00Z",
      "explanation": {
        "53029cf7-2070-4539-87f5-9fc754a0f041": {
          "value": true,
          "form": [
            "and",
            {
              "value": true,
              "form": [">=", {"path": ["fact", "pressure hulls"], "value": "3"}, "1"]
            },
            {
              "value": true,
              "form": ["=", {"path": ["fact", "warp cores"], "value": "0"}, "0"]
            },
            {
              "value": true,
              "form": [">" {"path": ["fact", "docking ports"], "value": "18"}, "9"]
            }
          ]
        }
      }
    }
  ],
  "transaction_uuid": "d3653a4a-4ebe-426e-a04d-dbebec00e97f"
}
```

`get_nodes()` (without the nodename argument) is deprecated, but is included for coverage of the API.  It
will return the same structure, but for all nodes with their historical check-in information.

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
  pin             Pin a node to a group
  unpin           Unpin a node from groups

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
