# Maram - RAM Usage Bar

Application macOS ultra-légère affichant l'utilisation RAM sous la menu bar.

## Compilation

```bash
swift build
```

## Exécution

```bash
swift run
```

## Caractéristiques

- Barre rouge horizontale sous la menu bar
- Largeur proportionnelle à l'utilisation RAM
- Mise à jour toutes les 2 secondes
- Fenêtre transparente et non-interactive
- Consommation CPU minimale (< 0.1%)
- Utilise sysctl() natif macOS pour les statistiques
