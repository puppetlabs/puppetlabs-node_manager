<!-- markdownlint-disable MD024 -->
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [v1.1.0](https://github.com/puppetlabs/puppetlabs-node_manager/tree/v1.1.0) - 2024-09-16

[Full Changelog](https://github.com/puppetlabs/puppetlabs-node_manager/compare/v1.0.1...v1.1.0)

### Added

- node_group type: Allow uppercase letters in environment names [#95](https://github.com/puppetlabs/puppetlabs-node_manager/pull/95) ([bastelfreak](https://github.com/bastelfreak))

## [v1.0.1](https://github.com/puppetlabs/puppetlabs-node_manager/tree/v1.0.1) - 2024-07-05

[Full Changelog](https://github.com/puppetlabs/puppetlabs-node_manager/compare/0.8.0...v1.0.1)

### Added

- (CAT-1731) improve handling of pinned nodes [#80](https://github.com/puppetlabs/puppetlabs-node_manager/pull/80) ([jonathannewman](https://github.com/jonathannewman))

### Fixed

- (CAT-1731) add rules tests [#81](https://github.com/puppetlabs/puppetlabs-node_manager/pull/81) ([jonathannewman](https://github.com/jonathannewman))

## [0.8.0](https://github.com/puppetlabs/puppetlabs-node_manager/tree/0.8.0) - 2023-06-14

[Full Changelog](https://github.com/puppetlabs/puppetlabs-node_manager/compare/0.7.6...0.8.0)

## [0.7.6](https://github.com/puppetlabs/puppetlabs-node_manager/tree/0.7.6) - 2023-04-05

[Full Changelog](https://github.com/puppetlabs/puppetlabs-node_manager/compare/0.7.5...0.7.6)

### Added

- Added ability to set the purge behavior for node group rules [#68](https://github.com/puppetlabs/puppetlabs-node_manager/pull/68) ([benjamin-robertson](https://github.com/benjamin-robertson))

## [0.7.5](https://github.com/puppetlabs/puppetlabs-node_manager/tree/0.7.5) - 2023-04-05

[Full Changelog](https://github.com/puppetlabs/puppetlabs-node_manager/compare/0.7.4...0.7.5)

### Added

- Added ability to set the purge behavior for node group rules [#68](https://github.com/puppetlabs/puppetlabs-node_manager/pull/68) ([benjamin-robertson](https://github.com/benjamin-robertson))
- Force override_environment to a symbol to maintain idempotency. [#67](https://github.com/puppetlabs/puppetlabs-node_manager/pull/67) ([bwilcox](https://github.com/bwilcox))
- Allow string bool input for override_environment [#61](https://github.com/puppetlabs/puppetlabs-node_manager/pull/61) ([reidmv](https://github.com/reidmv))

### Fixed

- Fixing bug where false variables are treated as nil [#69](https://github.com/puppetlabs/puppetlabs-node_manager/pull/69) ([rcontisplk](https://github.com/rcontisplk))
- Updated PE test versions [#65](https://github.com/puppetlabs/puppetlabs-node_manager/pull/65) ([WhatsARanjit](https://github.com/WhatsARanjit))
- Fixes bad schema issues with purge_behavior [#62](https://github.com/puppetlabs/puppetlabs-node_manager/pull/62) ([ody](https://github.com/ody))

## [0.7.4](https://github.com/puppetlabs/puppetlabs-node_manager/tree/0.7.4) - 2021-01-12

[Full Changelog](https://github.com/puppetlabs/puppetlabs-node_manager/compare/0.7.3...0.7.4)

### Added

- Implement `purge_behavior` parameter [#60](https://github.com/puppetlabs/puppetlabs-node_manager/pull/60) ([reidmv](https://github.com/reidmv))
- Adding Puppet5 tests [#50](https://github.com/puppetlabs/puppetlabs-node_manager/pull/50) ([WhatsARanjit](https://github.com/WhatsARanjit))

## [0.7.3](https://github.com/puppetlabs/puppetlabs-node_manager/tree/0.7.3) - 2019-12-27

[Full Changelog](https://github.com/puppetlabs/puppetlabs-node_manager/compare/0.7.2...0.7.3)

### Fixed

- Update metadata to indicate compatibility with Puppet 6 [#47](https://github.com/puppetlabs/puppetlabs-node_manager/pull/47) ([gabe-sky](https://github.com/gabe-sky))

## [0.7.2](https://github.com/puppetlabs/puppetlabs-node_manager/tree/0.7.2) - 2019-06-20

[Full Changelog](https://github.com/puppetlabs/puppetlabs-node_manager/compare/0.7.1...0.7.2)

## [0.7.1](https://github.com/puppetlabs/puppetlabs-node_manager/tree/0.7.1) - 2018-03-16

[Full Changelog](https://github.com/puppetlabs/puppetlabs-node_manager/compare/0.6.0...0.7.1)

### Added

- New task for update-classes API [#41](https://github.com/puppetlabs/puppetlabs-node_manager/pull/41) ([WhatsARanjit](https://github.com/WhatsARanjit))
- PR-35: Make error message more informative [#39](https://github.com/puppetlabs/puppetlabs-node_manager/pull/39) ([WhatsARanjit](https://github.com/WhatsARanjit))
- Added Console config_data support [#33](https://github.com/puppetlabs/puppetlabs-node_manager/pull/33) ([WhatsARanjit](https://github.com/WhatsARanjit))

### Fixed

- Fix Net::Http::Get constant error [#37](https://github.com/puppetlabs/puppetlabs-node_manager/pull/37) ([natemccurdy](https://github.com/natemccurdy))

## [0.6.0](https://github.com/puppetlabs/puppetlabs-node_manager/tree/0.6.0) - 2017-10-20

[Full Changelog](https://github.com/puppetlabs/puppetlabs-node_manager/compare/0.5.0...0.6.0)

## [0.5.0](https://github.com/puppetlabs/puppetlabs-node_manager/tree/0.5.0) - 2017-08-20

[Full Changelog](https://github.com/puppetlabs/puppetlabs-node_manager/compare/0.4.2...0.5.0)

### Added

- Release polish [#24](https://github.com/puppetlabs/puppetlabs-node_manager/pull/24) ([WhatsARanjit](https://github.com/WhatsARanjit))

### Fixed

- Issue 26 [#30](https://github.com/puppetlabs/puppetlabs-node_manager/pull/30) ([WhatsARanjit](https://github.com/WhatsARanjit))
- Issue 25 [#29](https://github.com/puppetlabs/puppetlabs-node_manager/pull/29) ([WhatsARanjit](https://github.com/WhatsARanjit))

## [0.4.2](https://github.com/puppetlabs/puppetlabs-node_manager/tree/0.4.2) - 2017-05-12

[Full Changelog](https://github.com/puppetlabs/puppetlabs-node_manager/compare/0.4.1...0.4.2)

### Added

- Initial commit on face [#21](https://github.com/puppetlabs/puppetlabs-node_manager/pull/21) ([WhatsARanjit](https://github.com/WhatsARanjit))
- Initial commit for remote authentication [#20](https://github.com/puppetlabs/puppetlabs-node_manager/pull/20) ([WhatsARanjit](https://github.com/WhatsARanjit))

### Fixed

- Hash order [#16](https://github.com/puppetlabs/puppetlabs-node_manager/pull/16) ([WhatsARanjit](https://github.com/WhatsARanjit))

## [0.4.1](https://github.com/puppetlabs/puppetlabs-node_manager/tree/0.4.1) - 2017-03-31

[Full Changelog](https://github.com/puppetlabs/puppetlabs-node_manager/compare/0.1.0...0.4.1)

### Added

- Added logic for cancelling unwanted classes/variables for issue #11 [#14](https://github.com/puppetlabs/puppetlabs-node_manager/pull/14) ([WhatsARanjit](https://github.com/WhatsARanjit))
- Fix markdown rendering issues [#12](https://github.com/puppetlabs/puppetlabs-node_manager/pull/12) ([natemccurdy](https://github.com/natemccurdy))
- Initial release of https provider [#8](https://github.com/puppetlabs/puppetlabs-node_manager/pull/8) ([WhatsARanjit](https://github.com/WhatsARanjit))

## [0.1.0](https://github.com/puppetlabs/puppetlabs-node_manager/tree/0.1.0) - 2015-04-11

[Full Changelog](https://github.com/puppetlabs/puppetlabs-node_manager/compare/0520df7a19dc78ebdd07338881a88be0e8a41eef...0.1.0)
