# 🎯 Maram - RAM Usage Monitor

Application macOS ultra-légère affichant l'utilisation de la RAM en temps réel.

## ✨ Fonctionnalités

- 📊 **Affichage RAM** - Barre visuelle montrant l'utilisation de la RAM en temps réel
- 🔄 **Mise à jour automatique** - Actualisation toutes les 2 secondes
- ⚡ **Ultra-légère** - Consommation CPU minimale (< 0.1%)
- 🎨 **Interface visuelle** - Barre bleue proportionnelle à l'utilisation RAM
- 🔧 **Native macOS** - Utilise `sysctl()` pour les statistiques système

## 🚀 Installation

### Option 1 - Compiler et lancer
```bash
swift build -c release
./build_app.sh
open build/Maram.app
```

### Option 2 - Lancer directement
```bash
swift build
swift run
```

### Option 3 - Version compilée
```bash
.build/release/Maram
```

## 📦 Structure du projet

```
Maram/
├── Sources/
│   ├── main.swift          # Point d'entrée
│   ├── AppDelegate.swift  # Gestion de l'application et fenêtre
│   ├── RAMMonitor.swift    # Surveillance de la RAM
│   └── RAMBarView.swift    # Vue de la barre
├── Package.swift           # Configuration Swift Package
├── build_app.sh            # Script de création de l'app bundle
└── README.md               # Ce fichier
```

## 🛠️ Développement

### Compiler en mode debug
```bash
swift build
```

### Compiler en mode release
```bash
swift build -c release
```

### Créer l'application bundle
```bash
./build_app.sh
```

### Arrêter l'application
```bash
killall Maram
```

## 📊 Comment ça marche

1. **RAMMonitor** utilise `sysctlbyname()` et `host_statistics64()` pour récupérer les statistiques RAM
2. **RAMBarView** affiche une barre bleue dont la largeur représente l'utilisation RAM
3. **Timer** met à jour l'affichage toutes les 2 secondes

## 🎮 Personnalisation

Tu peux modifier les paramètres dans `AppDelegate.swift` :
- `barHeight` - Hauteur de la fenêtre (actuellement 80px)
- `window.backgroundColor` - Couleur de la fenêtre
- Timer intervalle (actuellement 2.0 secondes)

## 📝 Notes

- Nécessite macOS 13.0 ou supérieur
- Compatible avec écrans multiples
- Application native Swift (SwiftUI/AppKit)

## 🐛 Problèmes connus

Aucun problème majeur détecté.

## 📄 Licence

Fait avec ❤️ pour surveiller votre RAM efficacement.
