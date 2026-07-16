import AppKit
import Combine
import SwiftUI

enum AppIcon {
    static var image: NSImage? {
        if let url = Bundle.main.url(forResource: "icon", withExtension: "png") {
            return NSImage(contentsOf: url)
        }
        return NSImage(named: "icon")
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    let settings = AppSettings()

    private var barWindows: [NSWindow] = []
    private var barViews: [PowerBarView] = []
    private let ramMonitor = RAMMonitor()
    private let batteryMonitor = BatteryMonitor()
    private let cpuMonitor = CPUMonitor()
    private let networkMonitor = NetworkMonitor()
    private var updateTimer: Timer?
    private var statusItem: NSStatusItem?
    private var settingsWindow: NSWindow?
    private var cancellables = Set<AnyCancellable>()
    private var currentOrientationVertical: Bool = false
    private var needsScreenRebuild = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.applicationIconImage = AppIcon.image
        setupStatusBar()
        setupWindows()
        startMonitoring()
        observeSettings()

        NotificationCenter.default.addObserver(
            self, selector: #selector(screensDidChange),
            name: NSApplication.didChangeScreenParametersNotification, object: nil
        )
    }

    @objc private func screensDidChange() {
        guard !needsScreenRebuild else { return }
        needsScreenRebuild = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            self.needsScreenRebuild = false
            
            if NSScreen.screens.count != self.barWindows.count {
                self.rebuildBarWindows()
            } else {
                self.forceReposition()
            }
        }
    }

    // MARK: - Status bar

    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem?.button {
            if let icon = AppIcon.image {
                let size: CGFloat = 18
                let resized = NSImage(size: NSSize(width: size, height: size), flipped: false) { dst in
                    icon.draw(in: NSRect(x: 0, y: 0, width: size, height: size),
                              from: .zero,
                              operation: .sourceOver,
                              fraction: 1)
                    return true
                }
                resized.isTemplate = false
                button.image = resized
                button.image?.isTemplate = false
                button.imagePosition = .imageOnly
            } else {
                button.title = "PKpowerlines"
            }
        }

        let menu = NSMenu()

        let settingsItem = NSMenuItem(title: "Réglages…", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(NSMenuItem.separator())

        let reloadItem = NSMenuItem(title: "Repositionner", action: #selector(forceReposition), keyEquivalent: "r")
        reloadItem.target = self
        menu.addItem(reloadItem)

        menu.addItem(NSMenuItem.separator())

        for (title, key) in [("Extra fin (4px)", "4"), ("Fin (8px)", "1"), ("Normal (12px)", "2"), ("Épais (20px)", "3")] {
            let item = NSMenuItem(title: title, action: #selector(setPresetHeight), keyEquivalent: key)
            item.target = self
            menu.addItem(item)
        }

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quitter PKpowerlines", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem?.menu = menu
        refreshMenuStates()
    }

    @objc private func openSettings() {
        if settingsWindow == nil {
            let rootView = SettingsView().environmentObject(settings)
            let hosting = NSHostingController(rootView: rootView)
            let window = NSWindow(contentViewController: hosting)
            window.title = "PKpowerlines — Réglages"
            window.subtitle = "Surveillance RAM & Batterie"
            window.styleMask = [.titled, .closable, .miniaturizable, .fullSizeContentView]
            window.titlebarAppearsTransparent = false
            window.isReleasedWhenClosed = false
            window.delegate = self
            window.setFrameAutosaveName("PKpowerlinesSettings")
            if let icon = AppIcon.image {
                window.representedURL = URL(fileURLWithPath: "/")
                NSApplication.shared.applicationIconImage = icon
            }
            settingsWindow = window
        }
        NSApp.activate(ignoringOtherApps: true)
        settingsWindow?.center()
        settingsWindow?.makeKeyAndOrderFront(nil)
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    @objc private func forceReposition() {
        rebuildBarWindows()
    }

    @objc private func setPresetHeight(_ sender: NSMenuItem) {
        switch sender.title {
        case "Extra fin (4px)": settings.barHeight = 4
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
            case "Extra fin (4px)": item.state = current == 4  ? .on : .off
            case "Fin (8px)":      item.state = current == 8  ? .on : .off
            case "Normal (12px)":  item.state = current == 12 ? .on : .off
            case "Épais (20px)":   item.state = current == 20 ? .on : .off
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
            .sink { [weak self] _ in self?.refreshMenuStates(); self?.resizeAndReposition() }
            .store(in: &cancellables)

        settings.$barPosition
            .removeDuplicates()
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] newPos in
                guard let self else { return }
                if newPos.isVertical != self.currentOrientationVertical {
                    self.currentOrientationVertical = newPos.isVertical
                    self.rebuildBarWindows()
                } else {
                    self.resizeAndReposition()
                }
            }
            .store(in: &cancellables)

        settings.$barOffset
            .removeDuplicates()
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.resizeAndReposition() }
            .store(in: &cancellables)

        settings.$barOpacity
            .removeDuplicates()
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] op in self?.barViews.forEach { $0.updateOpacity(op) } }
            .store(in: &cancellables)

        settings.$barFont
            .removeDuplicates()
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] f in self?.barViews.forEach { $0.updateFont(f) } }
            .store(in: &cancellables)

        settings.$showPercentage
            .removeDuplicates()
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] show in self?.barViews.forEach { $0.updateShowPercentage(show) } }
            .store(in: &cancellables)

        settings.$monitorType
            .removeDuplicates()
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.updateUsage() }
            .store(in: &cancellables)

        settings.$updateInterval
            .removeDuplicates()
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.restartTimer() }
            .store(in: &cancellables)

        settings.$networkMaxMBps
            .removeDuplicates()
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.updateUsage() }
            .store(in: &cancellables)

        Publishers.MergeMany(
            settings.$ramColorHex.map { _ in () },
            settings.$batteryColorHex.map { _ in () },
            settings.$batteryLowColorHex.map { _ in () },
            settings.$cpuColorHex.map { _ in () },
            settings.$networkColorHex.map { _ in () }
        )
        .dropFirst()
        .receive(on: RunLoop.main)
        .sink { [weak self] _ in self?.updateUsage() }
        .store(in: &cancellables)
    }

    // MARK: - Bar windows rebuild

    /// Reconstruit toutes les fenêtres barre (utile quand l'orientation change,
    /// car la géométrie fenêtre/vue bascule entre horizontal et vertical).
    private func rebuildBarWindows() {
        for window in barWindows { window.orderOut(nil) }
        barWindows.removeAll()
        barViews.removeAll()
        setupWindows()
        updateUsage()
    }

    // MARK: - Bar windows

    private func setupWindows() {
        currentOrientationVertical = settings.barPosition.isVertical
        for screen in NSScreen.screens {
            createWindow(for: screen)
        }
    }

    private func createWindow(for screen: NSScreen) {
        let frame = barFrame(on: screen)
        let view = PowerBarView()
        view.updateOrientation(settings.barPosition.isVertical)
        view.updateShowPercentage(settings.showPercentage)
        view.updateOpacity(settings.barOpacity)
        view.updateFont(settings.barFont)
        barViews.append(view)

        let window = NSWindow(
            contentRect: frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        window.level = NSWindow.Level(rawValue: Int(NSWindow.Level.statusBar.rawValue) + 1)
        window.backgroundColor = .clear
        window.isOpaque = false
        window.ignoresMouseEvents = true
        window.collectionBehavior = [.canJoinAllSpaces, .stationary]
        window.contentView = view
        barWindows.append(window)
        window.orderFrontRegardless()
    }

    private func barFrame(on screen: NSScreen) -> NSRect {
        let sf = screen.frame
        let thickness = settings.barHeight
        let offset = settings.barOffset
        switch settings.barPosition {
        case .top:
            return NSRect(x: sf.origin.x, y: sf.maxY - thickness - offset, width: sf.width, height: thickness)
        case .bottom:
            return NSRect(x: sf.origin.x, y: sf.minY + offset, width: sf.width, height: thickness)
        case .left:
            return NSRect(x: sf.origin.x + offset, y: sf.origin.y, width: thickness, height: sf.height)
        case .right:
            return NSRect(x: sf.maxX - thickness - offset, y: sf.origin.y, width: thickness, height: sf.height)
        }
    }

    private func resizeAndReposition() {
        let screens = NSScreen.screens
        
        for (index, window) in barWindows.enumerated() {
            if index < screens.count {
                let screen = screens[index]
                let newFrame = barFrame(on: screen)
                
                if newFrame != window.frame {
                    window.setFrame(newFrame, display: true, animate: false)
                }
            }
        }
        
        if barWindows.count != screens.count {
            rebuildBarWindows()
        }
    }

    // MARK: - Monitoring

    private func startMonitoring() {
        updateUsage()
        restartTimer()
    }

    private func restartTimer() {
        updateTimer?.invalidate()
        updateTimer = Timer.scheduledTimer(withTimeInterval: settings.updateInterval, repeats: true) { [weak self] _ in
            self?.updateUsage()
        }
    }

    private func updateUsage() {
        switch settings.monitorType {
        case .ram:
            let usage = ramMonitor.getRAMUsage()
            let color = NSColor(settings.ramColor)
            let label = "\(Int(usage.usedPercentage))%"
            DispatchQueue.main.async { [weak self] in
                self?.barViews.forEach {
                    $0.updateUsage(percentage: usage.usedPercentage, color: color, label: label)
                }
            }
        case .battery:
            let battery = batteryMonitor.getBatteryUsage()
            let threshold = settings.batteryLowThreshold
            let chargingColor = NSColor(settings.chargingColor)
            let lowColor = NSColor(settings.batteryLowColor)
            let normalColor = NSColor(settings.batteryColor)
            DispatchQueue.main.async { [weak self] in
                guard battery.percentage >= 0 else {
                    self?.barViews.forEach {
                        $0.updateUsage(percentage: 0, color: .gray, label: "Pas de batterie")
                    }
                    return
                }
                let color: NSColor
                if battery.isCharging {
                    color = chargingColor
                } else if battery.percentage < Double(threshold) {
                    color = lowColor
                } else {
                    color = normalColor
                }
                let prefix = battery.isCharging ? "⚡ " : ""
                let label = "\(prefix)\(Int(battery.percentage))%"
                self?.barViews.forEach {
                    $0.updateUsage(percentage: battery.percentage, color: color, label: label)
                }
            }
        case .cpu:
            let usage = cpuMonitor.getCPUUsage()
            let color = NSColor(settings.cpuColor)
            let label = "\(Int(usage.percentage))%"
            DispatchQueue.main.async { [weak self] in
                self?.barViews.forEach {
                    $0.updateUsage(percentage: usage.percentage, color: color, label: label)
                }
            }
        case .network:
            let usage = networkMonitor.getNetworkUsage(maxMBps: settings.networkMaxMBps)
            let color = NSColor(settings.networkColor)
            let label = "↓ \(Self.formatSpeed(usage.downloadKBps))  ↑ \(Self.formatSpeed(usage.uploadKBps))"
            DispatchQueue.main.async { [weak self] in
                self?.barViews.forEach {
                    $0.updateUsage(percentage: usage.percentage, color: color, label: label)
                }
            }
        }
    }

    private static func formatSpeed(_ kbps: Double) -> String {
        if kbps < 1 { return "0 KB/s" }
        if kbps < 1024 { return "\(Int(kbps)) KB/s" }
        return String(format: "%.1f MB/s", kbps / 1024)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}

extension AppDelegate: NSWindowDelegate {}
