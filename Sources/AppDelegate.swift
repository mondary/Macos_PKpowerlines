import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var ramBarWindows: [NSWindow] = []
    var ramBarViews: [RAMBarView] = []
    var monitor: RAMMonitor
    var updateTimer: Timer?
    var statusItem: NSStatusItem?
    var currentBarHeight: CGFloat = 12

    override init() {
        self.monitor = RAMMonitor()
        super.init()
        loadPreferences()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusBar()
        setupWindows()
        startMonitoring()
    }

    func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.title = "RAM"
        }

        let menu = NSMenu()

        menu.addItem(NSMenuItem.separator())

        let thinItem = NSMenuItem(title: "Fin (8px)", action: #selector(setThinHeight), keyEquivalent: "1")
        thinItem.state = currentBarHeight == 8 ? .on : .off
        thinItem.target = self
        menu.addItem(thinItem)

        let normalItem = NSMenuItem(title: "Normal (12px)", action: #selector(setNormalHeight), keyEquivalent: "2")
        normalItem.state = currentBarHeight == 12 ? .on : .off
        normalItem.target = self
        menu.addItem(normalItem)

        let thickItem = NSMenuItem(title: "Épais (20px)", action: #selector(setThickHeight), keyEquivalent: "3")
        thickItem.state = currentBarHeight == 20 ? .on : .off
        thickItem.target = self
        menu.addItem(thickItem)

        menu.addItem(NSMenuItem.separator())

        menu.addItem(NSMenuItem(title: "Quitter Maram", action: #selector(quitApp), keyEquivalent: "q"))
        statusItem?.menu = menu
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    @objc func setThinHeight() {
        setBarHeight(8)
    }

    @objc func setNormalHeight() {
        setBarHeight(12)
    }

    @objc func setThickHeight() {
        setBarHeight(20)
    }

    func setBarHeight(_ height: CGFloat) {
        currentBarHeight = height
        savePreferences()
        updateMenuStates()
        resizeWindows()
    }

    func updateMenuStates() {
        guard let menu = statusItem?.menu else { return }

        for item in menu.items {
            switch item.title {
            case "Fin (8px)":
                item.state = currentBarHeight == 8 ? .on : .off
            case "Normal (12px)":
                item.state = currentBarHeight == 12 ? .on : .off
            case "Épais (20px)":
                item.state = currentBarHeight == 20 ? .on : .off
            default:
                break
            }
        }
    }

    func resizeWindows() {
        for window in ramBarWindows {
            guard let screen = NSScreen.screens.first(where: { screen in
                screen.frame.intersects(window.frame)
            }) else { continue }

            let screenFrame = screen.frame
            let visibleFrame = screen.visibleFrame
            let barY = visibleFrame.maxY - currentBarHeight
            let barX = screenFrame.origin.x

            window.setFrame(
                NSRect(x: barX, y: barY, width: screenFrame.width, height: currentBarHeight),
                display: true,
                animate: false
            )
        }
    }

    func loadPreferences() {
        let height = UserDefaults.standard.double(forKey: "barHeight")
        if height > 0 {
            currentBarHeight = CGFloat(height)
        }
    }

    func savePreferences() {
        UserDefaults.standard.set(Double(currentBarHeight), forKey: "barHeight")
    }

    func setupWindows() {
        for screen in NSScreen.screens {
            let screenFrame = screen.frame
            let visibleFrame = screen.visibleFrame

            let barY = visibleFrame.maxY - currentBarHeight
            let barX = screenFrame.origin.x

            let ramBarView = RAMBarView()
            ramBarViews.append(ramBarView)

            let window = NSWindow(
                contentRect: NSRect(x: barX, y: barY, width: screenFrame.width, height: currentBarHeight),
                styleMask: .borderless,
                backing: .buffered,
                defer: false
            )

            window.level = .statusBar
            window.backgroundColor = .clear
            window.isOpaque = false
            window.ignoresMouseEvents = true
            window.collectionBehavior = [.canJoinAllSpaces, .stationary]
            window.contentView = ramBarView

            ramBarWindows.append(window)
            window.orderFrontRegardless()
        }
    }

    func startMonitoring() {
        updateRAMUsage()
        updateTimer = Timer.scheduledTimer(
            withTimeInterval: 2.0,
            repeats: true
        ) { [weak self] _ in
            self?.updateRAMUsage()
        }
    }

    func updateRAMUsage() {
        let usage = monitor.getRAMUsage()
        DispatchQueue.main.async { [weak self] in
            self?.ramBarViews.forEach { $0.updateUsage(usage) }
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}
