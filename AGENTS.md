# Instructions pour l'agent

## Skills
Consulter le dossier `.agent/-skills/` en priorité, en particulier :
- `skill_SCAFFOLD_create_vanilla_project.md` — structure du projet
- `skill_WRITE_create_project_readme_fr_en.md` — README FR/EN

## Architecture
Application macOS native (Swift / AppKit + SwiftUI).

```
src/macos/Maram/
├── App/           # @main App, AppDelegate, settings, monitors, vue barre
├── Views/Settings/  # Fenêtre de réglages SwiftUI
└── Resources/     # Info.plist, assets (à venir)
```

- `release/macos/Maram.app` après build (pas dans le repo)
- Pas de `dist/` ni de `build/` versionné

## Build
```bash
swift build                              # debug
./build_app.sh                           # release universel (arm64 + x86_64) → release/macos/Maram.app
```

## Règles
- Swift natif uniquement (pas de framework JS, pas de bundler)
- Releases versionnées dans `release/macos/` (jamais à la racine)
- Secrets dans `secrets/` (gitignoré)
- README FR + EN alignés

## Layout du projet (scaffold macOS natif)
Voir `skill_SCAFFOLD_create_vanilla_project.md` Layout A.
