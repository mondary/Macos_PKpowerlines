import AppKit

class RAMBarView: NSView {
    private var redBar: NSView?
    private var currentPercentage: Double = 0

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.darkGray.cgColor

        let bar = NSView()
        bar.wantsLayer = true
        bar.layer?.backgroundColor = NSColor.systemRed.cgColor
        addSubview(bar)
        self.redBar = bar
    }

    override func layout() {
        super.layout()
        updateBarFrame()
    }

    private func updateBarFrame() {
        let width = bounds.width * currentPercentage
        redBar?.frame = NSRect(x: 0, y: 0, width: width, height: bounds.height)
    }

    func updateUsage(_ usage: RAMUsage) {
        currentPercentage = min(max(usage.usedPercentage, 0), 100) / 100.0
        updateBarFrame()
    }
}
