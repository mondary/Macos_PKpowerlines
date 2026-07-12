# Maram

![Project icon](icon.png)

[🇬🇧 EN](README_en.md) · [🇫🇷 FR](README.md)

✨ Native macOS menu-bar app that displays a real-time bar at the top of every screen: RAM or battery. Universal Intel + Apple Silicon binary.

## ✅ Features

- 📊 **Two modes** — RAM (active + wired) or Battery (percentage, charging state, dynamic color)
- 🖥️ **Multi-screen** — one bar per screen
- 🌌 **Always visible** — every Space, status bar level, click-through
- 🎨 **Custom colors** — RAM, Battery, Low-battery, Charging colors via ColorPicker
- 🎚️ **Custom height** — slider 4–40px + 3 presets (⌘1/⌘2/⌘3)
- 💧 **Opacity** — 20% to 100%
- ↕️ **Position** — top or bottom + pixel-by-pixel offset (can overlap the menu bar)
- ⏱️ **Frequency** — refresh every 1–10s
- 🧩 **Universal binary** — `arm64` + `x86_64`
- 🪟 **SwiftUI settings window** — 3-tab sidebar, native macOS style

## 🧠 Usage

1. Launch the app → the bar appears at the top.
2. Click **Maram** in the menu bar:
   - **Settings…** (⌘,) — switch mode and adjust height
   - Height presets (⌘1 / ⌘2 / ⌘3)
   - **Quit** (⌘Q)

## ⚙️ Settings

| Setting | Values | Access |
|---|---|---|
| Source | RAM / Battery | Settings → General |
| Frequency | 1–10s | Settings → General |
| Height | 4–40px | Settings → Appearance (slider) |
| Height presets | 8 / 12 / 20px | Settings → Appearance or ⌘1/⌘2/⌘3 |
| Opacity | 20–100% | Settings → Appearance |
| RAM color | ColorPicker | Settings → Appearance |
| Battery color | ColorPicker | Settings → Appearance |
| Low-battery color | ColorPicker + threshold | Settings → Appearance |
| Position | Top / Bottom | Settings → Position |
| Quit | — | ⌘Q |

## 📦 Build & Package

**Debug build:**
```bash
swift run
```

**Universal release build + `.app` bundle:**
```bash
./build_app.sh
open release/macos/Maram.app
```

`build_app.sh` compiles as a universal binary (`--arch arm64 --arch x86_64`) and produces `release/macos/Maram.app`.

**Verify architecture:**
```bash
file release/macos/Maram.app/Contents/MacOS/Maram
# → Mach-O universal binary with 2 architectures: [x86_64] [arm64]
```

## 🧪 Stop

```bash
killall Maram
```

## 🛠️ Development

```
Maram/
├── src/
│   └── macos/
│       └── Maram/
│           ├── App/
│           │   ├── MaramApp.swift            # @main SwiftUI App + Settings scene
│           │   ├── AppDelegate.swift         # Status bar, bar windows, monitoring
│           │   ├── AppSettings.swift         # ObservableObject (UserDefaults)
│           │   ├── MonitorType.swift         # {.ram, .battery}
│           │   ├── RAMMonitor.swift          # sysctl/host_statistics64
│           │   ├── BatteryMonitor.swift      # IOKit (IOPMPowerSource)
│           │   └── PowerBarView.swift        # AppKit bar view
│           └── Views/
│               └── Settings/
│                   ├── SettingsView.swift            # Root TabView
│                   ├── GeneralSettingsView.swift     # Mode + live preview
│                   └── AppearanceSettingsView.swift  # Slider + presets
├── release/macos/                            # Build output (gitignored)
├── benchmark/                                # References, screenshots
├── secrets/                                  # Credentials (gitignored)
├── Package.swift                             # SwiftPM (macOS 13+, links IOKit)
├── build_app.sh                              # Universal build + bundle
├── AGENTS.md                                 # Agent instructions
├── LICENSE                                   # MIT
├── README.md / README_en.md
├── VERSION / CHANGELOG.md
└── icon.png
```

- **Platform**: macOS 13.0+
- **Dependencies**: none (native AppKit + SwiftUI + IOKit)
- **Architectures**: arm64 + x86_64 (universal)
- **Activation**: `LSUIElement` (pure menu-bar, no Dock icon)

## 🧾 Changelog

See [CHANGELOG.md](CHANGELOG.md).

## 🔗 Links

- French README: [README.md](README.md)
