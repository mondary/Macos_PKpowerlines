# PKpowerlines — Laius store

## Nom

PKpowerlines

## Tagline

- **FR** : Une barre powerline temps réel en haut de chaque écran de votre Mac.
- **EN** : A real-time powerline bar at the top of every Mac screen.

## Description courte (≤ 150 caractères)

- **FR** : Barre macOS en temps réel : RAM, CPU, réseau ou batterie, directement dans le bord de chaque écran. Native, légère, universelle.
- **EN**: Real-time macOS bar: RAM, CPU, network or battery, right on the edge of every screen. Native, lightweight, universal.

## Description longue

- **FR** :

  PKpowerlines affiche une fine barre powerline en temps réel sur le bord de chaque écran de votre Mac : mémoire (RAM), charge CPU, débit réseau ou état de la batterie, avec pourcentage intégré.

  100 % native (Swift, AppKit + SwiftUI, zéro dépendance), l'app se fond dans le système : toujours visible sur tous les Spaces, au niveau de la barre système, sans être dérangée par les clics (click-through).

  Personnalisez tout : source, couleur, police (7 au choix), hauteur (4–40 px), opacité, position (haut, bas, gauche, droite), offset au pixel près, fréquence de rafraîchissement (1–10 s). Une barre par écran, binaire universel Intel + Apple Silicon.

- **EN**:

  PKpowerlines shows a real-time powerline bar on the edge of every Mac screen: memory (RAM), CPU load, network throughput or battery status, with a built-in percentage.

  100% native (Swift, AppKit + SwiftUI, zero dependencies), the app blends into the system: always visible on every Space, at status-bar level, and click-through.

  Customize everything: source, color, font (7 choices), height (4–40 px), opacity, position (top, bottom, left, right), pixel-perfect offset, refresh rate (1–10 s). One bar per screen, universal Intel + Apple Silicon binary.

## Tags

macOS, menu bar, powerline, system monitor, RAM, CPU, network, battery, native, Swift, open source

## FAQ

- **Quelles plateformes ?** macOS 13.0 et plus. Binaire universel : Apple Silicon (arm64) et Intel (x86_64). Pas de version Windows/Linux.
- **Quelles sources peuvent être affichées ?** RAM (active + wired), charge CPU globale, débit réseau (↓/↑) et batterie (pourcentage, état de charge, couleur dynamique si faible).
- **L'app consomme-t-elle beaucoup de ressources ?** Non. La fréquence de mise à jour est réglable de 1 à 10 s (défaut 2 s) ; plus elle est longue, plus la consommation est faible.
- **Des données sont-elles collectées ?** Aucune. Tout est mesuré localement (sysctl, IOKit, getifaddrs), rien ne sort du Mac.
- **Peut-on masquer le pourcentage ?** Oui, la barre powerline reste affichée, seule la texte disparaît (automatiquement sous 8 px de hauteur).
- **Comment positionner la barre ?** Haut, bas, gauche ou droite de chaque écran, avec un offset réglé au pixel (elle peut chevaucher la menu bar).
- **Comment quitter l'app ?** Icône dans la barre des menus → Quitter (⌘Q), ou `killall PKpowerlines`.
