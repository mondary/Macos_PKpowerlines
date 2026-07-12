import AppKit

final class PowerBarView: NSView {
    private var barFill: NSView?
    private var percentageLabel: NSTextField?
    private var currentPercentage: Double = 0
    private var currentColor: NSColor = .systemRed
    private var currentLabel: String = "0%"
    private var opacity: Double = 1.0
    private var font: BarFont = .systemBold

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
        layer?.backgroundColor = NSColor.darkGray.withAlphaComponent(0.6).cgColor

        let bar = NSView()
        bar.wantsLayer = true
        bar.layer?.backgroundColor = currentColor.withAlphaComponent(opacity).cgColor
        addSubview(bar)
        self.barFill = bar

        let label = NSTextField(labelWithString: "0%")
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
        let barHeight = bounds.height
        let width = bounds.width * currentPercentage
        barFill?.frame = NSRect(x: 0, y: 0, width: width, height: barHeight)

        percentageLabel?.stringValue = currentLabel

        guard barHeight >= 8 else {
            percentageLabel?.isHidden = true
            return
        }
        percentageLabel?.isHidden = false

        let fontSize = max(6, min(barHeight * 0.75, 22))
        let nsFont = font.nsFont(size: fontSize)
        percentageLabel?.font = nsFont

        guard let label = percentageLabel else { return }
        let fontHeight = nsFont.boundingRectForFont.height
        let labelWidth: CGFloat = 60
        let labelHeight = max(fontHeight, fontSize + 2)
        let y = (barHeight - labelHeight) / 2
        var labelX = width - labelWidth - 5
        if labelX < 5 { labelX = 5 }
        label.frame = NSRect(x: labelX, y: y, width: labelWidth, height: labelHeight)
    }

    func updateUsage(percentage: Double, color: NSColor, label: String) {
        currentPercentage = min(max(percentage, 0), 100) / 100.0
        currentColor = color
        currentLabel = label
        barFill?.layer?.backgroundColor = color.withAlphaComponent(opacity).cgColor
        updateBarFrame()
    }

    func updateOpacity(_ value: Double) {
        opacity = value
        barFill?.layer?.backgroundColor = currentColor.withAlphaComponent(opacity).cgColor
    }

    func updateFont(_ value: BarFont) {
        font = value
        updateBarFrame()
    }
}
