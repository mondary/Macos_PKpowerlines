import AppKit

final class PowerBarView: NSView {
    private var barFill: NSView?
    private var percentageLabel: NSTextField?
    private var currentPercentage: Double = 0
    private var currentColor: NSColor = .systemRed
    private var currentLabel: String = "0%"
    private var opacity: Double = 1.0
    private var font: BarFont = .systemBold
    private var isVertical: Bool = false
    private var showPercentageFlag: Bool = true

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
        if isVertical {
            layoutVertical()
        } else {
            layoutHorizontal()
        }
    }

    // MARK: - Horizontal (haut / bas)

    private func layoutHorizontal() {
        let barHeight = bounds.height
        let width = bounds.width * currentPercentage
        barFill?.frame = NSRect(x: 0, y: 0, width: width, height: barHeight)

        percentageLabel?.stringValue = currentLabel
        percentageLabel?.frameRotation = 0

        let canShow = showPercentageFlag && barHeight >= 8
        percentageLabel?.isHidden = !canShow
        guard canShow else { return }

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

    // MARK: - Vertical (gauche / droite)

    private func layoutVertical() {
        let w = bounds.width
        let h = bounds.height
        let fillHeight = h * currentPercentage
        barFill?.frame = NSRect(x: 0, y: 0, width: w, height: fillHeight)

        percentageLabel?.stringValue = currentLabel

        // La taille de police s'adapte à l'ÉPAISSEUR (largeur) de la barre.
        let canShow = showPercentageFlag && w >= 8
        percentageLabel?.isHidden = !canShow
        guard canShow else { return }

        let fontSize = max(6, min(w * 0.75, 22))
        let nsFont = font.nsFont(size: fontSize)
        percentageLabel?.font = nsFont

        guard let label = percentageLabel else { return }

        // Frame pré-rotation : largeur = longueur du texte, hauteur = épaisseur police.
        let textLength: CGFloat = 60
        let textThickness = max(nsFont.boundingRectForFont.height, fontSize + 2)

        // Centre visuel souhaité : centré horizontalement dans la barre, vers le haut du remplissage.
        let cx = w / 2
        let desiredCy = fillHeight - textLength / 2 - 5
        let minCy = textLength / 2 + 5
        let maxCy = h - textLength / 2 - 5
        let cy = max(minCy, min(desiredCy, maxCy))

        let frameX = cx - textLength / 2
        let frameY = cy - textThickness / 2
        label.frame = NSRect(x: frameX, y: frameY, width: textLength, height: textThickness)
        // Lecture de bas en haut (-90°). Le centre reste invariant après rotation.
        label.frameRotation = -90
    }

    // MARK: - Public setters

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

    func updateOrientation(_ vertical: Bool) {
        guard isVertical != vertical else { return }
        isVertical = vertical
        updateBarFrame()
    }

    func updateShowPercentage(_ show: Bool) {
        guard showPercentageFlag != show else { return }
        showPercentageFlag = show
        updateBarFrame()
    }
}
