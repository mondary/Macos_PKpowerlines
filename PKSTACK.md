# PKSTACK — skills utilisées sur PKpowerlines

| Étape | Skill | Ce qu'elle a produit |
|---|---|---|
| Commits, version, changelog | `-pk-COMMIT` | CalVer `2026.10.x`, `CHANGELOG.md` source de vérité, READMEs FR/EN synchronisés, Ko-fi dans les deux READMEs |
| Build natif | `macos-build` | `build_app.sh` (SwiftPM, binaire universel arm64 + x86_64), app menu-bar `LSUIElement` |
| Captures réelles | `pk-bureau-agent` | Captures de la fenêtre de réglages sur l'écran virtuel, états batterie simulés |
| Landing + kit promo | `premium-promo-media` | `store/index.html` bilingue FR/EN (jardin interactif), `store/assets/` (bannière, cartes, police), `store/v2/` |
| Release Stable | `pk-app-release` | DMG (`packaging/`), tag `vYYYY.MM.PATCH`, GitHub Release, cask `mondary/tap/pkpowerlines` |
| Auto-update | `publish-macos-sparkle` | `appcast.xml` Stable + `appcast-dev.xml`, archive ZIP signée EdDSA |
| Présence hub | `app-presence-sync` | Entrée FR/EN du hub `Web_HubApps`, publication `www/apps/PKpowerlines/` |
