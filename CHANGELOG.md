## 2019-06-20 - Release 0.7.2

### Summary

- `Update to allow get_nodes() without argument`

#### Bugfixes

- Unpin actions had an errant pry statement

## 2018-03-15 - Release 0.7.1

## Summary

- Typo fix in README
- Change of repo name to puppet-node_manager

## 2018-03-15 - Release 0.7.0

### Summary

- Added task for update-classes endpoint
- JRuby method fix for Net::Http

## 2018-01-31 - Release 0.6.1

### Summary

- Typo in face output
- JRuby method fix

## 2017-10-20 - Release 0.6.0

### Summary

- Added `pin` action to face
- Added `data` parameter to `node_group` type for Console data
- Added support for `data` parameter to `https` provider
- Added `config_data` argument to puppet-less provider

## 2017-08-20 - Release 0.5.0

### Summary

- Can remove parameters from classes
- Can upin nodes from a group
- Added a puppet-less provider for node_group in bash
- Removed puppet_environment type and provider
- Removed puppetclassify provider and gem dependency

#### Bugfixes
- Provider submits nulls for removed parameters to remove them
- Submitting `''` to rules can remove everything


## 2017-05-12  - Release 0.4.2

### Summary

- Added a `node_manager` face for classifier API
- Added ability to manage node_groups using SSL or token authentication
- Added ability to manage node_groups from a remote client
- Set `https` provider as default

#### Bugfixes

- `classes` attribute Hash is now deep-sorted to maintain idempotency

## 2017-03-31 - Release 0.4.1

### Summary

- Added `description` attribute to groups

#### Bugfixes

- Added logic for cancelling unwanted classes/variables
- Able to now submit empty class/variables values

## 2017-03-30 - Release 0.4.0

### Summary

- Added `https` provider which doesn't need `puppeclassify` gem
- Added deprecation notice for `puppetclassify` provider

## 2016-10-26 - Release 0.3.0
### Summary

Needed to pin some gems because Ruby 2.1.x is approaching end of life.

#### Bugfixes
- Hardened ruby load issues on agents

## 2015-11-15 - Release 0.2.1
### Summary

Add some bugfixes.

#### Bugfixes
- Added empty dependencies to metadata.json to fix `puppet module list` error.
