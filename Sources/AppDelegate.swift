import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var barWindows: [NSWindow] = []
    var barViews: [PowerBarView] = []
    let ramMonitor = RAMMonitor()
    let batteryMonitor = BatteryMonitor()
    var updateTimer: Timer?
    var statusItem: NSStatusItem?
    var settingsController: SettingsWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusBar()
        setupWindows()
        startMonitoring()
    }

    // MARK: - Status bar

    func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.title = "Maram"
        }

        let menu = NSMenu()

        let settingsItem = NSMenuItem(title: "Réglages…", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(NSMenuItem.separator())

        let thinItem = NSMenuItem(title: "Fin (8px)", action: #selector(setThinHeight), keyEquivalent: "1")
        thinItem.target = self
        menu.addItem(thinItem)

        let normalItem = NSMenuItem(title: "Normal (12px)", action: #selector(setNormalHeight), keyEquivalent: "2")
        normalItem.target = self
        menu.addItem(normalItem)

        let thickItem = NSMenuItem(title: "Épais (20px)", action: #selector(setThickHeight), keyEquivalent: "3")
        thickItem.target = self
        menu.addItem(thickItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quitter Maram", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem?.menu = menu
        updateMenuStates()
    }

    @objc func openSettings() {
        if settingsController == nil {
            let controller = SettingsWindowController()
            controller.delegate = self
            settingsController = controller
        }
        settingsController?.refreshUI()
        settingsController?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    @objc func setThinHeight() { setBarHeight(8) }
    @objc func setNormalHeight() { setBarHeight(12) }
    @objc func setThickHeight() { setBarHeight(20) }

    func setBarHeight(_ height: CGFloat) {
        AppPreferences.barHeight = height
        updateMenuStates()
        resizeWindows()
    }

    func updateMenuStates() {
        guard let menu = statusItem?.menu else { return }
        let current = AppPreferences.barHeight
        for item in menu.items {
            switch item.title {
            case "Fin (8px)":     item.state = current == 8  ? .on : .off
            case "Normal (12px)": item.state = current == 12 ? .on : .off
            case "Épais (20px)":  item.state = current == 20 ? .on : .off
            default: break
            }
        }
    }

    // MARK: - Windows

    func setupWindows() {
        let height = AppPreferences.barHeight
        for screen in NSScreen.screens {
            let screenFrame = screen.frame
            let visibleFrame = screen.visibleFrame
            let barY = visibleFrame.maxY - height
            let barX = screenFrame.origin.x

            let view = PowerBarView()
            barViews.append(view)

            let window = NSWindow(
                contentRect: NSRect(x: barX, y: barY, width: screenFrame.width, height: height),
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

    func resizeWindows() {
        let height = AppPreferences.barHeight
        for window in barWindows {
            guard let screen = NSScreen.screens.first(where: { screen in
                screen.frame.intersects(window.frame)
            }) else { continue }

            let screenFrame = screen.frame
            let visibleFrame = screen.visibleFrame
            let barY = visibleFrame.maxY - height
            let barX = screenFrame.origin.x

            window.setFrame(
                NSRect(x: barX, y: barY, width: screenFrame.width, height: height),
                display: true,
                animate: false
            )
        }
    }

    // MARK: - Monitoring

    func startMonitoring() {
        updateUsage()
        updateTimer = Timer.scheduledTimer(
            withTimeInterval: 2.0,
            repeats: true
        ) { [weak self] _ in
            self?.updateUsage()
        }
    }

    func updateUsage() {
        switch AppPreferences.monitorType {
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

extension AppDelegate: SettingsDelegate {
    func settingsDidChange() {
        resizeWindows()
        updateUsage()
    }
}
