import AppKit
import Combine
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    let settings = AppSettings()

    private var barWindows: [NSWindow] = []
    private var barViews: [PowerBarView] = []
    private let ramMonitor = RAMMonitor()
    private let batteryMonitor = BatteryMonitor()
    private var updateTimer: Timer?
    private var statusItem: NSStatusItem?
    private var settingsWindow: NSWindow?
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
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

        for (title, key) in [("Fin (8px)", "1"), ("Normal (12px)", "2"), ("Épais (20px)", "3")] {
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
        if settingsWindow == nil {
            let rootView = SettingsView().environmentObject(settings)
            let hosting = NSHostingController(rootView: rootView)
            let window = NSWindow(contentViewController: hosting)
            window.title = "Maram — Réglages"
            window.styleMask = [.titled, .closable, .miniaturizable, .fullSizeContentView]
            window.isReleasedWhenClosed = false
            window.delegate = self
            window.setFrameAutosaveName("MaramSettings")
            settingsWindow = window
        }
        NSApp.activate(ignoringOtherApps: true)
        settingsWindow?.center()
        settingsWindow?.makeKeyAndOrderFront(nil)
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
            .sink { [weak self] _ in self?.refreshMenuStates(); self?.resizeAndReposition() }
            .store(in: &cancellables)

        settings.$barPosition
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

        Publishers.Merge3(
            settings.$ramColorHex.map { _ in () },
            settings.$batteryColorHex.map { _ in () },
            settings.$batteryLowColorHex.map { _ in () }
        )
        .dropFirst()
        .receive(on: RunLoop.main)
        .sink { [weak self] _ in self?.updateUsage() }
        .store(in: &cancellables)
    }

    // MARK: - Bar windows

    private func setupWindows() {
        for screen in NSScreen.screens {
            createWindow(for: screen)
        }
    }

    private func createWindow(for screen: NSScreen) {
        let frame = barFrame(on: screen)
        let view = PowerBarView()
        view.updateOpacity(settings.barOpacity)
        barViews.append(view)

        let window = NSWindow(
            contentRect: frame,
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

    private func barFrame(on screen: NSScreen) -> NSRect {
        let sf = screen.frame
        let vf = screen.visibleFrame
        let h = settings.barHeight
        switch settings.barPosition {
        case .top:
            return NSRect(x: sf.origin.x, y: vf.maxY - h, width: sf.width, height: h)
        case .bottom:
            return NSRect(x: sf.origin.x, y: vf.minY, width: sf.width, height: h)
        }
    }

    private func resizeAndReposition() {
        for window in barWindows {
            guard let screen = NSScreen.screens.first(where: { $0.frame.intersects(window.frame) }) else { continue }
            window.setFrame(barFrame(on: screen), display: true, animate: false)
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
        }
    }

    // MARK: - NSWindowDelegate

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}
