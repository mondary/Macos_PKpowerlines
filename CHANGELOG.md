# Changelog

## [1.1.0] - 2026-07-12
### Added
- Universal binary release (arm64 + x86_64) via `build_app.sh`
- Battery mode (IOKit / IOPMPowerSource) with charging state
- Settings window: mode selector (RAM/Batterie) + height slider (4–40px)
- Dynamic colors per mode (RAM=red, Battery=green/red/blue)
- `MonitorType`, `AppPreferences`, `BatteryMonitor`, `SettingsWindowController`

### Changed
- Refactored `RAMBarView` → generic `PowerBarView`
- `Package.swift` now links IOKit
- Menu bar item renamed "RAM" → "Maram" with Settings entry

## [1.0.0] - 2026-07-12
### Added
- Initial release — real-time RAM bar, multi-screen, 3 height presets, persistence

## [0.10] - 2026-07-12
### Added
- Initial project scaffold
