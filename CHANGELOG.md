# Changelog

## [1.2.0] - 2026-07-13
### Added
- Restructuration selon le scaffold PK (`src/macos/Maram/`, `release/macos/`)
- Fenêtre de réglages SwiftUI (TabView Général/Apparence) — style PKwindowsManagement
- `AppSettings: ObservableObject` avec `@Published` (remplace l'enum AppPreferences)
- Aperçu live de la barre dans l'onglet Général
- Onglet Apparence : slider de hauteur + presets cliquables
- `LICENSE` MIT, `AGENTS.md`, `benchmark/`, `secrets/`
- `LSUIElement` (app menu-bar pure, sans icône Dock)

### Changed
- `@main` SwiftUI App + `Settings` scene (remplace `main.swift`)
- AppDelegate observe `AppSettings` via Combine
- Build universel sort dans `release/macos/Maram.app`
- `Package.swift` pointe vers `src/macos/Maram`

### Fixed
- Crash mode Batterie : `IOPSGetPowerSourceDescription` utilisait `takeRetainedValue()` (over-release) → corrigé en `takeUnretainedValue()`

## [1.1.0] - 2026-07-12
### Added
- Universal binary release (arm64 + x86_64) via `build_app.sh`
- Battery mode (IOKit / IOPMPowerSource)
- Settings window: mode selector + height slider
- `MonitorType`, `AppPreferences`, `BatteryMonitor`, `SettingsWindowController`
- Dynamic colors per mode

### Changed
- Refactored `RAMBarView` → generic `PowerBarView`
- `Package.swift` now links IOKit

## [1.0.0] - 2026-07-12
### Added
- Version initiale — barre RAM temps réel, multi-écrans, 3 hauteurs, persistance

## [0.10] - 2026-07-12
### Added
- Initial project scaffold
