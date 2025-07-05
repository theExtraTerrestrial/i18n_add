## [Unreleased]

## [0.3.0] - 2025-07-05

### Changed
- **Major refactoring for improved modularity and maintainability**
- Refactored YamlProcessor to eliminate excessive parameter passing by using instance variables
- Refactored CLI class to follow single-responsibility principle with helper classes
- Updated error handling to use SystemExit exceptions instead of direct exit calls for better testability

### Added
- Comprehensive RDoc-compliant documentation for key methods
- New helper classes: CLIConfig, TranslationEntry, FileMapBuilder, CLIError
- New YAML processor helper classes: ProcessorState, KeyContext
- Enhanced error handling with proper exception catching in tests

### Fixed
- Fixed test suite issues where exit calls were causing test processes to terminate
- Improved CLI help system to work correctly with tests
- Enhanced error message formatting and display

### Technical Improvements
- Eliminated 11+ redundant keyword arguments across multiple methods
- Improved code organization with clear separation of concerns
- Enhanced testability with proper exception handling
- All tests now pass consistently (40+ tests, 200+ assertions)

## [0.2.0] - 2025-07-03

- Add comprehensive GitHub repository configuration
- Add CI/CD workflows for automated testing across multiple Ruby versions
- Add automated security auditing with bundle-audit
- Add GitHub issue and pull request templates
- Add automated release workflow triggered by git tags
- Add repository badges for gem version, CI status, and code style
- Add security policy (SECURITY.md)
- Improve project discoverability and community engagement

## [0.1.1] - 2025-07-03

- Add contributing guidelines and development documentation
- Add version management Rake tasks
- Document conventional commit format and release process

## [0.1.0] - 2025-07-03

- Initial release
- Command-line tool for adding/updating i18n translations in YAML files
- Support for nested keys and multiple locales
- Custom file path templates with %{locale} placeholder
- Efficient in-place YAML file updates
