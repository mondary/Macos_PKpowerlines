import AppKit

final class PowerBarView: NSView {
    private var barFill: NSView?
    private var percentageLabel: NSTextField?
    private var currentPercentage: Double = 0
    private var currentColor: NSColor = .systemRed
    private var currentLabel: String = "0%"

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
        bar.layer?.backgroundColor = currentColor.cgColor
        addSubview(bar)
        self.barFill = bar

        let label = NSTextField(labelWithString: "0%")
        label.font = NSFont.boldSystemFont(ofSize: 10)
        label.textColor = NSColor.white
        label.backgroundColor = .clear
        label.isBezeled = false
        label.alignment = .left
        addSubview(label)
        self.percentageLabel = label
    }

    override func layout() {
        super.layout()
        updateBarFrame()
    }

    private func updateBarFrame() {
        let width = bounds.width * currentPercentage
        barFill?.frame = NSRect(x: 0, y: 0, width: width, height: bounds.height)
        percentageLabel?.stringValue = currentLabel

        if let label = percentageLabel {
            let labelWidth: CGFloat = 50
            let labelHeight: CGFloat = 14
            var labelX = width - labelWidth - 5
            if labelX < 5 { labelX = 5 }
            label.frame = NSRect(x: labelX, y: -2, width: labelWidth, height: labelHeight)
        }
    }

    func updateUsage(percentage: Double, color: NSColor, label: String) {
        currentPercentage = min(max(percentage, 0), 100) / 100.0
        currentColor = color
        currentLabel = label
        barFill?.layer?.backgroundColor = color.cgColor
        updateBarFrame()
    }
}
