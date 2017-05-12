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
