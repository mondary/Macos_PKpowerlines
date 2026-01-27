import AppKit

class RAMBarView: NSView {
    private var redBar: NSView?
    private var percentageLabel: NSTextField?
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

        redBar?.frame = NSRect(x: 0, y: 0, width: width, height: bounds.height)

        let percentage = Int(currentPercentage * 100)
        percentageLabel?.stringValue = "\(percentage)%"

        if let label = percentageLabel {
            let labelWidth = 40
            let labelHeight: CGFloat = 14
            var labelX = width - CGFloat(labelWidth) - 5

            if labelX < 5 {
                labelX = 5
            }

            label.frame = NSRect(x: labelX, y: -2, width: CGFloat(labelWidth), height: labelHeight)
        }
    }

    func updateUsage(_ usage: RAMUsage) {
        currentPercentage = min(max(usage.usedPercentage, 0), 100) / 100.0
        updateBarFrame()
    }
}
