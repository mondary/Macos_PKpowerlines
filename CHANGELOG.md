# Changelog

## [1.9.1] - 2026-07-16
### Added
- **Preset hauteur « Extra fin » (4px)** — accessible via `⌘4` dans le menu bar et bouton « Extra fin » dans les réglages

## [1.9.0] - 2026-07-13
### Added
- **Deux nouvelles sources** : **CPU** (`host_statistics64` / `HOST_CPU_LOAD_INFO`) et **Réseau** (`getifaddrs` delta ↓/↑ toutes interfaces)
- **Positions gauche / droite** : barre verticale sur les bords latéraux (remplissage bas→haut, % rotated)
- **Toggle « Afficher le % »** : masque le texte tout en gardant la barre powerline
- **Couleur CPU** + **couleur Réseau** personnalisables (ColorPicker)
- **Plafond débit réseau** réglable (1–1000 MB/s = 100 % de la barre)

### Changed
- Le picker de source passe en `.menu` (4 sources avec icônes)
- `MonitorType` étendu (`.cpu`, `.network`) ; `BarPosition` étendu (`.left`, `.right` + `isVertical`)
- `PowerBarView` supporte l'orientation verticale + le flag `showPercentage`
- Les fenêtres barre sont reconstruites quand l'orientation bascule (horizontal ↔ vertical)
- Offset s'applique horizontalement pour les positions gauche/droite
- Observers Combine élargis (`Publishers.MergeMany` sur les 5 couleurs)

## [1.8.0] - 2026-07-13
### Added
- **Page À propos** dans la sidebar (style Dockspace) : icône 88px centrée, titre, version, auteur, texte + footer liens (GitHub, Issues)
- Application **live** du menu bar spacing pendant le drag (debounce 300ms)

### Changed
- Slider « Padding » et « Spacing » réappliquent en direct via `Task.sleep` + `MenuBarSpacing.write`
- État "Apple / personnalisée" recalculé en live
- Suppression du bouton « Appliquer » (n'est plus nécessaire)

## [1.7.0] - 2026-07-13
### Added
- **Onglet Menu Bar** : réglage du padding interne + espacement entre items de la menu bar macOS (style Sindre Sorhus)
  - Lecture/écriture via `CFPreferences` sur `NSStatusItemSelectionPadding` et `NSStatusItemSpacing` (host courant)
  - Application via `killall ControlCenter`
  - Bouton « Restaurer défauts Apple »
  - Banner d'avertissement (interrompt AirDrop/Screen Share)
  - Indicateur d'état (Apple / personnalisée)

### Changed
- **Réorganisation** : sidebar 2 onglets au lieu de 3
  - **Powerline** : source, fréquence, hauteur, opacité, police, couleurs RAM/Batterie/Faible, position, offset, presets, raccourcis
  - **Menu Bar** : padding + spacing + reset
- Suppression de GeneralSettingsView / AppearanceSettingsView / PositionSettingsView (fusionnés dans `PowerlineSettingsView`)

## [1.6.0] - 2026-07-13
### Changed
- **Renommage Maram → PKpowerlines** (executable, bundle, fenêtre, menu, sidebar)
- Fenêtre de réglages agrandie (880×560 min)
- Nouveaux defaults : Batterie / 9 px / offset 0 / opacité 50 % / position Très haut

### Removed
- Anciens dossiers `src/macos/Maram/`, bundle `Maram.app`

## [1.5.0] - 2026-07-13
### Added
- **Icône app** `icon.png` utilisée partout : menu bar (remplace le texte "Maram"), sidebar réglages, icône app
- `icon.png` bundlé dans `Contents/Resources/icon.png` (build_app.sh)
- Onglet **Apparence → Police** : 7 polices (Système, Helvetica Neue, Menlo, SF Mono, Monaco, Courier) avec aperçu multi-tailles
- Enum `BarFont` + helper `AppIcon`

### Changed
- `%` toujours centré verticalement dans la barre
- Taille de police auto-adaptative : `max(6, min(barHeight * 0.75, 22))` pt
- Label masqué automatiquement sous 8 px de hauteur
- `statusItem.lengthLength` = `squareLength` pour l'icône
- `NSImage.isTemplate = false` pour garder l'icône en couleur dans la menu bar

## [1.4.0] - 2026-07-13
### Added
- **Offset vertical pixel par pixel** depuis le bord brut de l'écran (slider -40 à +400 + stepper 1px)
- 4 préréglages rapides d'offset (Très haut / Sous menu bar / +50 / +150)
- Hint dynamique selon la position (chevauche menu bar / sous menu bar / au-dessus du Dock)
- `window.level` passé au-dessus de `statusBar` → la barre peut chevaucher la menu bar

### Changed
- `barFrame` utilise `screen.frame` (bord brut) au lieu de `visibleFrame` (zone utile)
- `barOffset: CGFloat` ajouté à `AppSettings` (default 0 = bord brut)

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
