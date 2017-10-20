# Node_manager scripts

#### Table of Contents

1. [Overview](#overview)
1. [Example](#example)
1. [Setup](#setup)
1. [Usage](#usage)

## Overview

Manipulate node_groups from a system without Puppet installed.

## Example

```
[root@server ~/node_manager/scripts]# ./node_group.sh -n 'Example Group' \
--rule '["or", ["=", "name", "node.whatsaranjit.com"]]' \
--classes '{"vim": {}}' --variables '{"foo": "bar"}'
New group ID: 15e0c815-e3ca-48e3-a467-e86e5b9d025e
```

## Setup

Place a file at `~/.node_managerrc` following this example:

```
MASTER=master.whatsaranjit.com     # Defaults to hostname -f
PORT=4433                          # Defaults to 4433
TOKEN='<your_token>'
```

## Usage

```
Usage: ./node_group.sh [options] [UID]

 -n| --name      The name of the node_group.
                *Required to create a new group.

 -x| --ensure      Set to [present|absent] for existence.
                Default: present

 -d| --description    Description of group.

 -e| --environment    Puppet environment for group.
                Default: production

 -o| --override    Set to [true|false] for environment group.
                Default: false

 -p| --parent      Parent group UID.
                Default: 00000000-0000-4000-8000-000000000000

 -c| --classes      Hash of classes and parameters.
                Example: '{ "vim": {} }'

 -r| --rule       Array of rules for matching.
                Example: '["or", ["=", "name", "node.whatsaranjit.com"]]'

 -v| --variables    Variables to set in the group.
                Example: '{ "foo": "bar" }'

 -a| --config_data    Configuration data for the group.
                Example: '{ "vim": { "vim_package": "vim-common" } }'

 -h| --help      Display this help message.
 ```

### Create a new group

```
[root@server ~/node_manager/scripts]# ./node_group.sh -n 'Example Group'
```
The `--name` flag is required.  All other flags are optional.

### Update an existing group

```
[root@server ~/node_manager/scripts]# ./node_group.sh -d 'New description' 15e0c815-e3ca-48e3-a467-e86e5b9d025e
```
You must edit a group by giving the UID.

### Delete a group

```
[root@server ~/node_manager/scripts]# ./node_group.sh --ensure absent 15e0c815-e3ca-48e3-a467-e86e5b9d025e
```
You must delete a group by giving the UID.
