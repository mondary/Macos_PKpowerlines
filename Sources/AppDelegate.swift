import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var ramBarWindows: [NSWindow] = []
    var ramBarViews: [RAMBarView] = []
    var monitor: RAMMonitor
    var updateTimer: Timer?
    var statusItem: NSStatusItem?

    override init() {
        self.monitor = RAMMonitor()
        super.init()
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
        menu.addItem(NSMenuItem(title: "Quitter Maram", action: #selector(quitApp), keyEquivalent: "q"))
        statusItem?.menu = menu
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    func setupWindows() {
        let barHeight: CGFloat = 5

        for screen in NSScreen.screens {
            let screenFrame = screen.frame
            let visibleFrame = screen.visibleFrame

            // Position at top of visible frame (just below menubar)
            let barY = visibleFrame.maxY - barHeight
            let barX = screenFrame.origin.x

            let ramBarView = RAMBarView()
            ramBarViews.append(ramBarView)

            let window = NSWindow(
                contentRect: NSRect(x: barX, y: barY, width: screenFrame.width, height: barHeight),
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
