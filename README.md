# Maram

![Project icon](icon.png)

[🇫🇷 FR](README.md) · [🇬🇧 EN](README_en.md)

✨ Application macOS native (menu-bar) qui affiche une barre en temps réel en haut de chaque écran : RAM ou batterie. Binaire universel Intel + Apple Silicon.

## ✅ Fonctionnalités

- 📊 **Deux modes** — RAM (active + wired) ou Batterie (pourcentage, état de charge, couleur dynamique)
- 🖥️ **Multi-écrans** — une barre par écran
- 🌌 **Toujours visible** — tous les Spaces, niveau barre système, click-through
- 🎨 **Couleurs custom** — RAM, Batterie, Batterie faible, couleur de charge, toutes modifiables via ColorPicker
- 🔤 **Police custom** — 7 polices au choix, taille auto-adaptative, % centré verticalement
- 🎚️ **Hauteur custom** — slider 4–40px + 3 presets (⌘1/⌘2/⌘3)
- 💧 **Opacité** — de 20% à 100%
- ↕️ **Position** — haut ou bas + offset pixel par pixel (peut chevaucher la menu bar)
- ⏱️ **Fréquence** — mise à jour toutes les 1–10s
- 🧩 **Binaire universel** — `arm64` + `x86_64`
- 🪟 **Fenêtre de réglages SwiftUI** — sidebar 3 onglets style macOS natif

## 🧠 Utilisation

1. Lance l'app → la barre apparaît en haut.
2. Clique sur **Maram** dans la barre des menus :
   - **Réglages…** (⌘,) — change le mode et la hauteur
   - Presets hauteur (⌘1 / ⌘2 / ⌘3)
   - **Quitter** (⌘Q)

## ⚙️ Réglages

| Réglage | Valeurs | Accès |
|---|---|---|
| Source | RAM / Batterie | Réglages → Général |
| Fréquence | 1–10s | Réglages → Général |
| Hauteur | 4–40px | Réglages → Apparence (slider) |
| Presets hauteur | 8 / 12 / 20px | Réglages → Apparence ou ⌘1/⌘2/⌘3 |
| Opacité | 20–100% | Réglages → Apparence |
| Couleur RAM | ColorPicker | Réglages → Apparence |
| Couleur Batterie | ColorPicker | Réglages → Apparence |
| Couleur Batterie faible | ColorPicker + seuil | Réglages → Apparence |
| Position | Haut / Bas | Réglages → Position |
| Quitter | — | ⌘Q |

## 📦 Build & Package

**Build debug :**
```bash
swift run
```

**Build release universel + bundle `.app` :**
```bash
./build_app.sh
open release/macos/Maram.app
```

`build_app.sh` compile en universal binary (`--arch arm64 --arch x86_64`) et génère `release/macos/Maram.app`.

**Vérifier l'architecture :**
```bash
file release/macos/Maram.app/Contents/MacOS/Maram
# → Mach-O universal binary with 2 architectures: [x86_64] [arm64]
```

## 🧪 Arrêt

```bash
killall Maram
```

## 🛠️ Développement

```
Maram/
├── src/
│   └── macos/
│       └── Maram/
│           ├── App/
│           │   ├── MaramApp.swift            # @main SwiftUI App + Settings scene
│           │   ├── AppDelegate.swift         # Status bar, fenêtres barre, monitoring
│           │   ├── AppSettings.swift         # ObservableObject (UserDefaults)
│           │   ├── MonitorType.swift         # {.ram, .battery}
│           │   ├── RAMMonitor.swift          # sysctl/host_statistics64
│           │   ├── BatteryMonitor.swift      # IOKit (IOPMPowerSource)
│           │   └── PowerBarView.swift        # Vue AppKit de la barre
│           └── Views/
│               └── Settings/
│                   ├── SettingsView.swift            # TabView racine
│                   ├── GeneralSettingsView.swift     # Mode + aperçu live
│                   └── AppearanceSettingsView.swift  # Slider + presets
├── release/macos/                            # Sortie build (gitignoré)
├── benchmark/                                # Références, captures
├── secrets/                                  # Credentials (gitignoré)
├── Package.swift                             # SwiftPM (macOS 13+, IOKit linké)
├── build_app.sh                              # Build universel + bundle
├── AGENTS.md                                 # Instructions agent
├── LICENSE                                   # MIT
├── README.md / README_en.md
├── VERSION / CHANGELOG.md
└── icon.png
```

- **Plateforme** : macOS 13.0+
- **Dépendances** : aucune (AppKit + SwiftUI + IOKit natifs)
- **Architectures** : arm64 + x86_64 (universal)
- **Activation** : `LSUIElement` (menu-bar pure, pas d'icône Dock)

## 🧾 Changelog

Voir [CHANGELOG.md](CHANGELOG.md).

## 🔗 Liens

- README anglais : [README_en.md](README_en.md)
