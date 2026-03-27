# Changelog

## [0.1.3] - 2026-03-26

### Changed
- fix remote_invocable? to use class method for local dispatch

## [0.1.2] - 2026-03-22

### Changed
- Add legion-* sub-gems as runtime dependencies (logging, settings, json, cache, crypt, data, transport)
- Replace direct Legion::Logging calls with injected log helper in all runner modules
- Update spec_helper with real sub-gem helper stubs

## [0.1.1] - 2026-03-18

### Changed
- Enforce SUBSTRATE_TYPES validation in FermentationEngine#create_substrate (returns nil for invalid type)
- Enforce CATALYST_TYPES validation in FermentationEngine#catalyze (returns nil for invalid catalyst)

## [0.1.0] - 2026-03-18

### Added
- Initial release as domain consolidation gem
- Consolidated source extensions into unified domain gem under `Legion::Extensions::Agentic::<Domain>`
- All sub-modules loaded from single entry point
- Full spec suite with zero failures
- RuboCop compliance across all files
