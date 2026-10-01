# Changelog

## [2026.10.1] - 2026-10-01
### Changed
- Réorganisation du dépôt : assets store historiques dans `store/v1/`, landing pixel art dans `store/website/`, anciens visuels archivés dans `archives/`
- Icônes et captures des projets PK déplacées dans `src/macos/Resources/Project{Icons,Screenshots}` (page Bibliothèque intacte)
- `build_app.sh` lit désormais la version dans `CHANGELOG.md` (source de vérité) au lieu du fichier `VERSION`, supprimé

### Fixed
- Build release réparé : la suppression de `VERSION` cassait la génération de l'Info.plist
- READMEs : chemins des bannières et captures corrigés après la réorganisation du store, lien Ko-fi ajouté

## [2026.09.05] - 2026-09-11
### Changed
- Hauteur par défaut restaurée à « Extra fin » (`4 px`)
- Icône de menu bar envoyée en image intrinsèque `14 × 14 px` avec mise à l’échelle descendante uniquement

## [2026.09.04] - 2026-09-11
### Changed
- Numéro de version incrémenté pour identifier sans ambiguïté la build installée

## [2026.09.03] - 2026-09-11
### Fixed
- Démarrage du mouvement fluide après l’attachement effectif de la barre à sa fenêtre
- Mouvement rendu par la variation directe du remplissage, visible même sans charge active

## [2026.09.02] - 2026-09-11
### Added
- Mouvement fluide visible en continu ; pulsation et balayage accéléré ajoutés lorsque la batterie est en charge
- Version affichée en tête du menu de l’icône PKpowerlines

### Changed
- Icône de menu bar réduite visuellement de 10 %

## [2026.09.01] - 2026-09-05
### Added
- **Fenêtre Réglages refondue** (format PKMonitor) : sidebar dédiée avec recherche de sections, groupes « POWERLINE » et « PK PROJECTS », version en pied de sidebar
- **Page Bibliothèque** — les projets PK en cartes (icônes + captures), PKpowerlines en vedette, liens directs GitHub
- **Page Aide & don** — carte Ko-fi « Offrez-moi un café » + liens GitHub / Issues ; lien café ajouté au footer de la page À propos
- En-têtes de section (titre + sous-titre + icône) sur toutes les pages POWERLINE
- Icônes et captures des projets PK embarquées (`ProjectIcons/`, `ProjectScreenshots/` copiés dans le bundle par `build_app.sh`)

### Changed
- Version 2026.08.01 → 2026.09.01

## [2026.08.01] - 2026-08-23
### Added
- **Option « Forcer le % en batterie faible »** — sous le seuil « Faible » (zone rouge, hors charge), le pourcentage s'affiche en permanence même si « Afficher le % » est désactivé ; la barre s'épaissit à 12 px si trop fine pour le texte (toggle dans Réglages → Powerline, défaut activé)

### Changed
- Versioning passé au format PK `YYYY.MM.PATCH` ; `build_app.sh` lit désormais le fichier `VERSION` (plus de version en dur dans l'Info.plist)

## [1.9.2] - 2026-07-17
### Added
- **Icône powerline menu bar** — remplace l'ancienne icône par un séparateur powerline blanc (`powerline_white.png`, `isTemplate`) redimensionné à 66px
- Bascule automatique dark/light via `isTemplate`
- Fichiers `powerline_black.png` / `powerline_white.png` ajoutés dans `src/macos/Resources/`

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
