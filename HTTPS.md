# node_manager [![Build Status](https://travis-ci.org/WhatsARanjit/prosvcs-node_manager.svg)](https://travis-ci.org/WhatsARanjit/prosvcs-node_manager)

#### Table of Contents
1. [Overview](#overview)
1. [Requirements](#requirements)
1. [node_group type](#node_group)
1. [node_groups() function](#node_groups)

## Overview

Create and manage PE Console node groups as resources.
The `https` provider is meant to erase the dependecy on
the `puppetclassify` gem  This helps will runtime issues
when managing node_groups and installing the gem in the
same agent run.  To try it out:

```
node_group { 'Test new provider':
  ensure   => present,
  provider => 'https',
}
```

No changes need to be made.  When the `puppetclassify`
provider is dropped, the `https` provider will take over
as a seamless swap-in.

## Requirements:

- *nix operating system
- Puppet Enterprise >= 3.7.1  

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

#### Node_group parameters

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
UID. Default: `All Nodes`

* `rules`<br />
An array of classification rules. Default (empty array): `[]`

## Functions

### node_groups()

Retrieve all or one node_group and its data.

`node_groups()` will return:

```
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

```
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

## Maintainers
This repositority is largely the work of some Puppet community members.
It is not officially maintained by Puppet, or any individual in
particular.  Issues should be opened in Github.  Questions should be directed
at the individuals responsible for committing that particular code.
