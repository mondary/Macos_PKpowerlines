# Maram

![Project icon](icon.png)

[🇬🇧 EN](README_en.md) · [🇫🇷 FR](README.md)

✨ Native macOS app that displays a real-time RAM usage bar at the top of every screen.

## ✅ Features

- 📊 **Real-time RAM bar** — width proportional to usage (active + wired)
- 🖥️ **Multi-screen** — one bar per screen, top aligned
- 🌌 **Always visible** — shown in every Space, at status bar level
- 🎚️ **3 heights** — Thin (8px), Normal (12px), Thick (20px)
- 💾 **Persistent** — selected height is remembered across launches
- 🔄 **Auto refresh** — every 2 seconds
- ⚡ **Ultra-lightweight** — minimal CPU usage, click-through window

## 🧠 Usage

1. Launch the app → a red bar appears at the top of the screen with the % of RAM used.
2. Click **RAM** in the menu bar to change the height or quit.

## ⚙️ Settings

| Setting | Values | Shortcut |
|---|---|---|
| Thin height | 8px | ⌘1 |
| Normal height | 12px (default) | ⌘2 |
| Thick height | 20px | ⌘3 |
| Quit | — | ⌘Q |

## 📦 Build & Package

**Debug build + direct run:**
```bash
swift run
```

**Release build + `.app` creation:**
```bash
swift build -c release
./build_app.sh
open release/Maram.app
```

**Standalone executable (release):**
```bash
.build/release/Maram
```

## 🧪 Stop

```bash
killall Maram
```

## 🛠️ Development

```
Maram/
├── Sources/
│   ├── main.swift         # Entry point (NSApplication)
│   ├── AppDelegate.swift  # Status bar, windows, timer, preferences
│   ├── RAMMonitor.swift   # sysctl/host_statistics64 reading
│   └── RAMBarView.swift   # Bar view + % label
├── Package.swift          # Swift Package (macOS 13+)
├── build_app.sh           # Builds release/Maram.app bundle
└── README_en.md
```

- **Platform**: macOS 13.0+
- **Dependencies**: none (pure AppKit)

## 🧾 Changelog

- **1.0.0**: Initial release — real-time RAM bar, multi-screen, 3 heights, persistence.

## 🔗 Links

- French README: [README.md](README.md)
