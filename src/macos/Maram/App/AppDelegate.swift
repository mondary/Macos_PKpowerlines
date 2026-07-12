import AppKit
import Combine

final class AppDelegate: NSObject, NSApplicationDelegate {
    let settings = AppSettings()

    private var barWindows: [NSWindow] = []
    private var barViews: [PowerBarView] = []
    private let ramMonitor = RAMMonitor()
    private let batteryMonitor = BatteryMonitor()
    private var updateTimer: Timer?
    private var statusItem: NSStatusItem?
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        setupStatusBar()
        setupWindows()
        startMonitoring()
        observeSettings()
    }

    // MARK: - Status bar

    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.title = "Maram"

        let menu = NSMenu()

        let settingsItem = NSMenuItem(title: "Réglages…", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(NSMenuItem.separator())

        let presets: [(String, CGFloat, String)] = [
            ("Fin (8px)", 8, "1"),
            ("Normal (12px)", 12, "2"),
            ("Épais (20px)", 20, "3")
        ]
        for (title, _, key) in presets {
            let item = NSMenuItem(title: title, action: #selector(setPresetHeight), keyEquivalent: key)
            item.target = self
            menu.addItem(item)
        }

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quitter Maram", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem?.menu = menu
        refreshMenuStates()
    }

    @objc private func openSettings() {
        if #available(macOS 13, *) {
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        } else {
            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        }
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    @objc private func setPresetHeight(_ sender: NSMenuItem) {
        switch sender.title {
        case "Fin (8px)": settings.barHeight = 8
        case "Normal (12px)": settings.barHeight = 12
        case "Épais (20px)": settings.barHeight = 20
        default: break
        }
    }

    private func refreshMenuStates() {
        guard let menu = statusItem?.menu else { return }
        let current = settings.barHeight
        for item in menu.items {
            switch item.title {
            case "Fin (8px)":     item.state = current == 8  ? .on : .off
            case "Normal (12px)": item.state = current == 12 ? .on : .off
            case "Épais (20px)":  item.state = current == 20 ? .on : .off
            default: break
            }
        }
    }

    // MARK: - Settings observation

    private func observeSettings() {
        settings.$barHeight
            .removeDuplicates()
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.refreshMenuStates()
                self?.resizeWindows()
            }
            .store(in: &cancellables)

        settings.$monitorType
            .removeDuplicates()
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateUsage()
            }
            .store(in: &cancellables)
    }

    // MARK: - Bar windows

    private func setupWindows() {
        let height = settings.barHeight
        for screen in NSScreen.screens {
            let sf = screen.frame
            let vf = screen.visibleFrame
            let view = PowerBarView()
            barViews.append(view)

            let window = NSWindow(
                contentRect: NSRect(x: sf.origin.x, y: vf.maxY - height, width: sf.width, height: height),
                styleMask: .borderless,
                backing: .buffered,
                defer: false
            )
            window.level = .statusBar
            window.backgroundColor = .clear
            window.isOpaque = false
            window.ignoresMouseEvents = true
            window.collectionBehavior = [.canJoinAllSpaces, .stationary]
            window.contentView = view
            barWindows.append(window)
            window.orderFrontRegardless()
        }
    }

    private func resizeWindows() {
        let height = settings.barHeight
        for window in barWindows {
            guard let screen = NSScreen.screens.first(where: { $0.frame.intersects(window.frame) }) else { continue }
            let sf = screen.frame
            let vf = screen.visibleFrame
            window.setFrame(
                NSRect(x: sf.origin.x, y: vf.maxY - height, width: sf.width, height: height),
                display: true,
                animate: false
            )
        }
    }

    // MARK: - Monitoring

    private func startMonitoring() {
        updateUsage()
        updateTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.updateUsage()
        }
    }

    private func updateUsage() {
        switch settings.monitorType {
        case .ram:
            let usage = ramMonitor.getRAMUsage()
            let label = "\(Int(usage.usedPercentage))%"
            DispatchQueue.main.async { [weak self] in
                self?.barViews.forEach {
                    $0.updateUsage(percentage: usage.usedPercentage, color: .systemRed, label: label)
                }
            }
        case .battery:
            let battery = batteryMonitor.getBatteryUsage()
            DispatchQueue.main.async { [weak self] in
                guard battery.percentage >= 0 else {
                    self?.barViews.forEach {
                        $0.updateUsage(percentage: 0, color: .gray, label: "Pas de batterie")
                    }
                    return
                }
                let color: NSColor = battery.isCharging
                    ? .systemBlue
                    : (battery.percentage < 20 ? .systemRed : .systemGreen)
                let prefix = battery.isCharging ? "⚡ " : ""
                let label = "\(prefix)\(Int(battery.percentage))%"
                self?.barViews.forEach {
                    $0.updateUsage(percentage: battery.percentage, color: color, label: label)
                }
            }
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}
