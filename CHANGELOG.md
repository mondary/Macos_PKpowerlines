# Changelog

## [1.3.0] - 2026-07-13
### Added
- Fenêtre de réglages `NavigationSplitView` (sidebar Général / Apparence / Position) — style PKwindowsManagement
- Onglet **Apparence** : `ColorPicker` pour RAM, Batterie, Batterie faible + seuil + opacité
- Onglet **Position** : barre en haut ou en bas de l'écran + aperçu
- Onglet **Général** : fréquence de mise à jour (1–10s) réglable
- Helper `Color+Hex` pour la persistance des couleurs
- Enum `BarPosition` (.top / .bottom)

### Changed
- Ouverture des réglages fiable : `NSHostingController` géré par `AppDelegate` (remplace SwiftUI `Settings` scene qui ne s'ouvrait plus)
- Retour au pattern `main.swift` + `NSApplication.run()` (app menu-bar pure)
- `AppSettings` étendu : 9 propriétés `@Published` observées via Combine
- `PowerBarView` gère l'opacité dynamique

## [1.2.0] - 2026-07-13
### Added
- Restructuration selon le scaffold PK (`src/macos/Maram/`, `release/macos/`)
- Fenêtre de réglages SwiftUI (TabView Général/Apparence)
- `AppSettings: ObservableObject` (remplace l'enum AppPreferences)
- Aperçu live de la barre dans l'onglet Général
- `LICENSE` MIT, `AGENTS.md`, `benchmark/`, `secrets/`
- `LSUIElement` (app menu-bar pure)

### Changed
- `@main` SwiftUI App + `Settings` scene (remplace `main.swift`)
- AppDelegate observe `AppSettings` via Combine

### Fixed
- Crash mode Batterie : `IOPSGetPowerSourceDescription` utilisait `takeRetainedValue()` → `takeUnretainedValue()`

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
