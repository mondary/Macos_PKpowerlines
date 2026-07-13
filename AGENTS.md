# Instructions pour l'agent

## Architecture
Application macOS native (Swift / AppKit + SwiftUI), menu bar app.

```
src/macos/
├── App/            # @main + AppDelegate
├── Models/         # Types & préférences (AppSettings, BarFont, BarPosition, MonitorType, MenuBarSpacing)
├── Monitors/       # Lectures système (BatteryMonitor, RAMMonitor)
├── Views/
│   ├── PowerBarView.swift          # La barre de menu (AppKit)
│   └── Settings/                   # Fenêtre de réglages (SwiftUI)
├── Utils/          # Extensions & helpers (ColorHex)
└── Resources/      # Info.plist, Assets (à venir)
```

- `release/macos/PKpowerlines.app` après build (pas dans le repo)
- Pas de `dist/` ni de `build/` versionné

## Build
```bash
swift build                              # debug
./build_app.sh                           # release universel (arm64 + x86_64) → release/macos/PKpowerlines.app
```

## Règles
- Swift natif uniquement (pas de framework JS, pas de bundler)
- SwiftPM compile récursivement tout `.swift` sous `src/macos/` — l'organisation en sous-dossiers n'affecte pas le build
- Releases versionnées dans `release/macos/` (jamais à la racine)
- Secrets dans `secrets/` (gitignoré)
- README FR + EN alignés
