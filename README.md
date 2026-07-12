# Maram

![Project icon](icon.png)

[🇫🇷 FR](README.md) · [🇬🇧 EN](README_en.md)

✨ Application macOS native qui affiche une barre en temps réel en haut de chaque écran : utilisation RAM ou niveau de batterie. Binaire universel (Intel + Apple Silicon).

## ✅ Fonctionnalités

- 📊 **Deux modes** — RAM (active + wired) ou Batterie (pourcentage + état charge)
- 🎨 **Couleurs dynamiques** — RAM en rouge, batterie en vert/rouge/bleu selon l'état
- 🖥️ **Multi-écrans** — une barre par écran, alignée en haut
- 🌌 **Toujours visible** — affichée dans tous les Spaces, au niveau de la barre système
- 🎚️ **Hauteur personnalisable** — slider de 4px à 40px (plus 3 presets ⌘1/⌘2/⌘3)
- 💾 **Persistant** — mode et hauteur mémorisés entre les lancements
- 🔄 **Mise à jour auto** — toutes les 2 secondes
- 🧩 **Binaire universel** — Intel (x86_64) + Apple Silicon (arm64)
- ⚡ **Ultra-légère** — consommation CPU minimale, fenêtre click-through

## 🧠 Utilisation

1. Lance l'app → la barre apparaît en haut de l'écran.
2. Clique sur **Maram** dans la barre des menus :
   - **Réglages…** pour changer de mode et ajuster la hauteur
   - Presets hauteur : Fin (⌘1), Normal (⌘2), Épais (⌘3)
   - **Quitter** (⌘Q)

## ⚙️ Réglages

| Réglage | Valeurs | Raccourci |
|---|---|---|
| Mode | RAM / Batterie | Réglages… |
| Hauteur Fin | 8px | ⌘1 |
| Hauteur Normal | 12px (défaut) | ⌘2 |
| Hauteur Épais | 20px | ⌘3 |
| Hauteur custom | 4–40px | Réglages… (slider) |
| Quitter | — | ⌘Q |

## 📦 Build & Package

**Build debug + exécution directe :**
```bash
swift run
```

**Build release universel + création du `.app` :**
```bash
./build_app.sh
open release/Maram.app
```

Le script `build_app.sh` compile en universal binary (`--arch arm64 --arch x86_64`) et génère `release/Maram.app`.

**Vérifier l'architecture :**
```bash
file release/Maram.app/Contents/MacOS/Maram
# → Mach-O universal binary with 2 architectures: [x86_64] [arm64]
```

## 🧪 Arrêt

```bash
killall Maram
```

## 🛠️ Développement

```
Maram/
├── Sources/
│   ├── main.swift                # Point d'entrée (NSApplication)
│   ├── AppDelegate.swift         # Status bar, fenêtres, timer, monitoring
│   ├── AppPreferences.swift      # UserDefaults (monitorType, barHeight)
│   ├── MonitorType.swift         # Enum {.ram, .battery}
│   ├── RAMMonitor.swift          # Lecture sysctl/host_statistics64
│   ├── BatteryMonitor.swift      # IOKit (IOPMPowerSource)
│   ├── PowerBarView.swift        # Vue de la barre générique + label
│   └── SettingsWindowController.swift # Fenêtre de réglages
├── Package.swift                 # Swift Package (macOS 13+, IOKit linké)
├── build_app.sh                  # Build universel + bundle release/Maram.app
└── README.md
```

- **Plateforme** : macOS 13.0+
- **Dépendances** : aucune (AppKit + IOKit natifs)
- **Architectures** : arm64 + x86_64 (universal)

## 🧾 Changelog

- **1.1.0** : Binaire universel, mode Batterie (IOKit), fenêtre de réglages avec slider de hauteur, vue refactorisée en `PowerBarView` générique.
- **1.0.0** : Version initiale — barre RAM temps réel, multi-écrans, 3 hauteurs, persistance.

## 🔗 Liens

- README anglais : [README_en.md](README_en.md)
