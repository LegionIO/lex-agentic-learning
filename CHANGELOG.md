# Changelog

## [Unreleased]

### Fixed
- fix form_agenda return key from agenda_items to agenda to match GAIA phase wiring expectations

## [0.1.5] - 2026-03-31

### Added
- OutcomeListener sub-module: subscription actor wiring task completion events to cognitive model updates (#4)
- DomainExtractor helper: extracts learning domain from runner class names
- LessonBuilder helper: generates structured situation-lesson pairs for Apollo persistence
- MetaLearning, LearningRate, and Scaffolding models updated on each task outcome
- Per-agent scoped lessons written to Apollo knowledge store
- Settings toggles: outcome_listener, write_to_apollo, min_lesson_severity

## [0.1.4] - 2026-03-30

### Changed
- update to rubocop-legion 0.1.7, resolve all offenses

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
