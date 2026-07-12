# Maram

![Project icon](icon.png)

[🇬🇧 EN](README_en.md) · [🇫🇷 FR](README.md)

✨ Native macOS app that displays a real-time bar at the top of every screen: RAM usage or battery level. Universal binary (Intel + Apple Silicon).

## ✅ Features

- 📊 **Two modes** — RAM (active + wired) or Battery (percentage + charging state)
- 🎨 **Dynamic colors** — RAM in red, battery in green/red/blue depending on state
- 🖥️ **Multi-screen** — one bar per screen, top aligned
- 🌌 **Always visible** — shown in every Space, at status bar level
- 🎚️ **Custom height** — slider from 4px to 40px (plus 3 presets ⌘1/⌘2/⌘3)
- 💾 **Persistent** — mode and height remembered across launches
- 🔄 **Auto refresh** — every 2 seconds
- 🧩 **Universal binary** — Intel (x86_64) + Apple Silicon (arm64)
- ⚡ **Ultra-lightweight** — minimal CPU usage, click-through window

## 🧠 Usage

1. Launch the app → the bar appears at the top of the screen.
2. Click **Maram** in the menu bar:
   - **Settings…** to switch mode and adjust height
   - Height presets: Thin (⌘1), Normal (⌘2), Thick (⌘3)
   - **Quit** (⌘Q)

## ⚙️ Settings

| Setting | Values | Shortcut |
|---|---|---|
| Mode | RAM / Battery | Settings… |
| Thin height | 8px | ⌘1 |
| Normal height | 12px (default) | ⌘2 |
| Thick height | 20px | ⌘3 |
| Custom height | 4–40px | Settings… (slider) |
| Quit | — | ⌘Q |

## 📦 Build & Package

**Debug build + direct run:**
```bash
swift run
```

**Universal release build + `.app` creation:**
```bash
./build_app.sh
open release/Maram.app
```

`build_app.sh` compiles as a universal binary (`--arch arm64 --arch x86_64`) and produces `release/Maram.app`.

**Verify architecture:**
```bash
file release/Maram.app/Contents/MacOS/Maram
# → Mach-O universal binary with 2 architectures: [x86_64] [arm64]
```

## 🧪 Stop

```bash
killall Maram
```

## 🛠️ Development

```
Maram/
├── Sources/
│   ├── main.swift                # Entry point (NSApplication)
│   ├── AppDelegate.swift         # Status bar, windows, timer, monitoring
│   ├── AppPreferences.swift      # UserDefaults (monitorType, barHeight)
│   ├── MonitorType.swift         # Enum {.ram, .battery}
│   ├── RAMMonitor.swift          # sysctl/host_statistics64 reading
│   ├── BatteryMonitor.swift      # IOKit (IOPMPowerSource)
│   ├── PowerBarView.swift        # Generic bar view + label
│   └── SettingsWindowController.swift # Settings window
├── Package.swift                 # Swift Package (macOS 13+, links IOKit)
├── build_app.sh                  # Universal build + release/Maram.app bundle
└── README_en.md
```

- **Platform**: macOS 13.0+
- **Dependencies**: none (native AppKit + IOKit)
- **Architectures**: arm64 + x86_64 (universal)

## 🧾 Changelog

- **1.1.0**: Universal binary, Battery mode (IOKit), settings window with height slider, view refactored into generic `PowerBarView`.
- **1.0.0**: Initial release — real-time RAM bar, multi-screen, 3 heights, persistence.

## 🔗 Links

- French README: [README.md](README.md)
