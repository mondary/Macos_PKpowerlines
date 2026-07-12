# Maram

![Project icon](icon.png)

[🇫🇷 FR](README.md) · [🇬🇧 EN](README_en.md)

✨ Application macOS native qui affiche une barre d'utilisation de la RAM en temps réel, en haut de chaque écran.

## ✅ Fonctionnalités

- 📊 **Barre RAM en temps réel** — largeur proportionnelle à l'utilisation (active + wired)
- 🖥️ **Multi-écrans** — une barre par écran, alignée en haut
- 🌌 **Toujours visible** — affichée dans tous les Spaces, au niveau de la barre système
- 🎚️ **3 hauteurs** — Fin (8px), Normal (12px), Épais (20px)
- 💾 **Persistant** — la hauteur choisie est mémorisée entre les lancements
- 🔄 **Mise à jour auto** — toutes les 2 secondes
- ⚡ **Ultra-légère** — consommation CPU minimale, fenêtre invisible au clic

## 🧠 Utilisation

1. Lance l'app → une barre rouge apparaît en haut de l'écran avec le % de RAM utilisé.
2. Clique sur **RAM** dans la barre des menus pour changer la hauteur ou quitter.

## ⚙️ Réglages

| Réglage | Valeurs | Raccourci |
|---|---|---|
| Hauteur Fin | 8px | ⌘1 |
| Hauteur Normal | 12px (défaut) | ⌘2 |
| Hauteur Épais | 20px | ⌘3 |
| Quitter | — | ⌘Q |

## 📦 Build & Package

**Build debug + exécution directe :**
```bash
swift run
```

**Build release + création du `.app` :**
```bash
swift build -c release
./build_app.sh
open release/Maram.app
```

**Exécutable seul (release) :**
```bash
.build/release/Maram
```

## 🧪 Arrêt

```bash
killall Maram
```

## 🛠️ Développement

```
Maram/
├── Sources/
│   ├── main.swift         # Point d'entrée (NSApplication)
│   ├── AppDelegate.swift  # Status bar, fenêtres, timer, préférences
│   ├── RAMMonitor.swift   # Lecture sysctl/host_statistics64
│   └── RAMBarView.swift   # Vue de la barre + label %
├── Package.swift          # Swift Package (macOS 13+)
├── build_app.sh           # Création du bundle release/Maram.app
└── README.md
```

- **Plateforme** : macOS 13.0+
- **Dépendances** : aucune (AppKit pur)

## 🧾 Changelog

- **1.0.0** : Version initiale — barre RAM temps réel, multi-écrans, 3 hauteurs, persistance.

## 🔗 Liens

- README anglais : [README_en.md](README_en.md)
