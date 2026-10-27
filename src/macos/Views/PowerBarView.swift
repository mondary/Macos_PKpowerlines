import AppKit
import Dispatch
import QuartzCore

private final class FlowFillView: NSView {
    var fillColor: NSColor = .systemRed { didSet { updateColor() } }
    var fillOpacity: Double = 1 { didSet { updateColor() } }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        updateColor()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        wantsLayer = true
        updateColor()
    }

    private func updateColor() {
        layer?.backgroundColor = fillColor.withAlphaComponent(fillOpacity).cgColor
    }
}

final class PowerBarView: NSView {
    private var barFill: FlowFillView?
    private var trackLayer: CALayer?
    private var percentageLabel: NSTextField?
    private var currentPercentage: Double = 0
    private var currentColor: NSColor = .systemRed
    private var currentLabel: String = "0%"
    private var opacity: Double = 1.0
    private var font: BarFont = .systemBold
    private var isVertical: Bool = false
    private var barPosition: BarPosition = .top
    private var barThickness: CGFloat = 0
    private var showPercentageFlag: Bool = true
    private var forceShowText: Bool = false
    private var flowEnabled = true
    private var isCharging = false
    private var isDischarging = false
    private var isCriticalLow = false
    private var sparkEnabled = true
    private var criticalPulseEnabled = true
    private var consumptionEnabled = true
    private var flowPhase: CGFloat = 0
    private var flowTimer: DispatchSourceTimer?
    private var sparkLayer: CAGradientLayer?
    private var puffLayers: [CALayer] = []
    private var puffs: [SmokePuff] = []
    private var smokeTick = 0

    private struct SmokePuff {
        var position: CGPoint
        var velocity: CGVector
        var life: CGFloat
    }

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
        layer?.backgroundColor = NSColor.clear.cgColor

        // Fond sombre limité à l'épaisseur de la powerline (le reste de la fenêtre
        // peut être plus haut pour loger le texte : il doit rester transparent).
        let track = CALayer()
        track.backgroundColor = NSColor.darkGray.withAlphaComponent(0.6).cgColor
        layer?.addSublayer(track)
        self.trackLayer = track

        let bar = FlowFillView()
        bar.fillColor = currentColor
        bar.fillOpacity = opacity
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

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        restartFlowTimer()
    }

    deinit { flowTimer?.cancel() }

    private func updateBarFrame() {
        if isVertical {
            layoutVertical()
        } else {
            layoutHorizontal()
        }
    }

    // MARK: - Horizontal (haut / bas)

    private func layoutHorizontal() {
        let windowHeight = bounds.height
        let width = bounds.width * currentPercentage
        applyAnimatedFillFrame(wave: flowWave)

        percentageLabel?.stringValue = currentLabel
        percentageLabel?.frameRotation = 0

        let canShow = (showPercentageFlag && windowHeight >= 8) || forceShowText
        percentageLabel?.isHidden = !canShow
        guard canShow else { return }

        guard let label = percentageLabel else { return }

        let barT = effectiveBarThickness
        let overflows = windowHeight > barT + 0.5
        let fontSize = overflows ? 11 : max(6, min(windowHeight * 0.75, 22))
        let nsFont = font.nsFont(size: fontSize)
        percentageLabel?.font = nsFont
        percentageLabel?.alignment = .right

        let fontHeight = nsFont.boundingRectForFont.height
        let labelWidth: CGFloat = 60
        let labelHeight = max(fontHeight, fontSize + 2)
        // Texte posé sur la ligne et levé au-dessus du bord de l'écran quand la
        // ligne est plus fine : le haut dépasse hors de l'écran, le bas déborde
        // légèrement sous la ligne. La ligne reste collée au bord.
        let overflowLift: CGFloat = 4
        let y: CGFloat
        if overflows {
            y = barPosition == .top
                ? windowHeight - labelHeight + overflowLift
                : -overflowLift
        } else {
            y = (windowHeight - labelHeight) / 2
        }
        var labelX = width - labelWidth - 5
        if labelX < 5 { labelX = 5 }
        label.frame = NSRect(x: labelX, y: y, width: labelWidth, height: labelHeight)
    }

    // MARK: - Vertical (gauche / droite)

    private func layoutVertical() {
        let w = bounds.width
        let h = bounds.height
        let fillHeight = h * currentPercentage
        applyAnimatedFillFrame(wave: flowWave)

        percentageLabel?.stringValue = currentLabel

        // La taille de police s'adapte à l'ÉPAISSEUR (largeur) de la fenêtre.
        let canShow = (showPercentageFlag && w >= 8) || forceShowText
        percentageLabel?.isHidden = !canShow
        guard canShow else { return }

        let barT = effectiveBarThickness
        let overflows = w > barT + 0.5
        let fontSize = overflows ? 11 : max(6, min(w * 0.75, 22))
        let nsFont = font.nsFont(size: fontSize)
        percentageLabel?.font = nsFont

        guard let label = percentageLabel else { return }

        // Frame pré-rotation : largeur = longueur du texte, hauteur = épaisseur police.
        let textLength: CGFloat = 60
        let textThickness = max(nsFont.boundingRectForFont.height, fontSize + 2)

        // Texte posé sur la ligne, levé au-dessus du bord quand il déborde.
        let overflowLift: CGFloat = 4
        let cx: CGFloat = overflows
            ? (barPosition == .left ? textThickness / 2 - overflowLift : w - textThickness / 2 + overflowLift)
            : w / 2

        // Centre visuel souhaité : vers le haut du remplissage.
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

    private var effectiveBarThickness: CGFloat {
        let windowThickness = isVertical ? bounds.width : bounds.height
        guard barThickness > 0 else { return windowThickness }
        return min(barThickness, windowThickness)
    }

    // MARK: - Public setters

    func updateUsage(percentage: Double, color: NSColor, label: String) {
        currentPercentage = min(max(percentage, 0), 100) / 100.0
        currentColor = color
        currentLabel = label
        barFill?.fillColor = color
        updateBarFrame()
        restartFlowTimer()
    }

    func updateOpacity(_ value: Double) {
        opacity = value
        barFill?.fillOpacity = opacity
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

    func updateAnimatedFlow(_ animated: Bool) {
        flowEnabled = animated
        restartFlowTimer()
    }

    func updateCharging(_ charging: Bool) {
        isCharging = charging
        restartFlowTimer()
    }

    func updateDischarging(_ discharging: Bool) {
        guard isDischarging != discharging else { return }
        isDischarging = discharging
        if !isDischarging { clearSmoke() }
        restartFlowTimer()
    }

    func updateSparkEnabled(_ enabled: Bool) {
        guard sparkEnabled != enabled else { return }
        sparkEnabled = enabled
        if !enabled { sparkLayer?.isHidden = true }
        restartFlowTimer()
    }

    func updateCriticalPulseEnabled(_ enabled: Bool) {
        guard criticalPulseEnabled != enabled else { return }
        criticalPulseEnabled = enabled
        if !enabled {
            barFill?.fillOpacity = opacity
            percentageLabel?.alphaValue = 1
        }
        restartFlowTimer()
    }

    func updateConsumptionEnabled(_ enabled: Bool) {
        guard consumptionEnabled != enabled else { return }
        consumptionEnabled = enabled
        if !enabled { clearSmoke() }
        restartFlowTimer()
    }

    func updateCriticalLow(_ critical: Bool) {
        guard isCriticalLow != critical else { return }
        isCriticalLow = critical
        if !critical {
            barFill?.fillOpacity = opacity
            percentageLabel?.alphaValue = 1
        }
        restartFlowTimer()
    }

    private func restartFlowTimer() {
        // Le timer tourne pour la vague discrète (flux animé) ET pour les
        // effets d'état (pulsation critique, étincelle de charge), toujours actifs.
        let needsAnimation = flowEnabled || isCharging || isCriticalLow
            || (isDischarging && consumptionEnabled)
        guard needsAnimation, window != nil else {
            flowTimer?.cancel()
            flowTimer = nil
            flowPhase = 0
            applyAnimatedFillFrame(wave: 0)
            sparkLayer?.isHidden = true
            clearSmoke()
            barFill?.fillOpacity = opacity
            percentageLabel?.alphaValue = 1
            return
        }
        guard flowTimer == nil else { return }

        let timer = DispatchSource.makeTimerSource(queue: .main)
        timer.schedule(deadline: .now(), repeating: .milliseconds(50), leeway: .milliseconds(5))
        timer.setEventHandler { [weak self] in self?.advanceFlow() }
        flowTimer = timer
        timer.resume()
    }

    private func advanceFlow() {
        flowPhase += isCharging ? 0.42 : 0.24
        applyAnimatedFillFrame(wave: flowWave + erosionOffset())
        tickEffects()
    }

    /// Érosion du bord de remplissage en décharge : petites entailles qui
    /// mangent le bord, sans jamais dépasser le niveau réel.
    private func erosionOffset() -> CGFloat {
        guard isDischarging, consumptionEnabled, window != nil else { return 0 }
        let length = isVertical ? bounds.height : bounds.width
        let room = min(length * currentPercentage, length * (1 - currentPercentage))
        guard room > 2 else { return 0 }
        let t = Date().timeIntervalSinceReferenceDate
        let noise = abs(sin(t * 41.3) * 0.6 + sin(t * 27.7) * 0.4)
        return -CGFloat(noise) * min(1.6, room)
    }

    // MARK: - Effets (rouge critique / charge électrique)

    private func tickEffects() {
        let t = Date().timeIntervalSinceReferenceDate
        if isCriticalLow, criticalPulseEnabled, window != nil {
            // Battement d'alerte : plancher relevé pour rester visible même avec
            // une opacité utilisateur basse — la barre pulse entre ~40 % et 80 %/100 %.
            let alertBase = max(opacity, 0.8)
            let pulse = abs(sin(t * 3.4))
            barFill?.fillOpacity = alertBase * (0.5 + 0.5 * pulse)
            percentageLabel?.alphaValue = CGFloat(0.55 + 0.45 * pulse)
        } else {
            barFill?.fillOpacity = opacity
            percentageLabel?.alphaValue = 1
        }
        updateSpark(t: t)
        updateSmoke()
    }

    /// Bande lumineuse qui balaie le remplissage avec un scintillement électrique pendant la charge.
    private func updateSpark(t: TimeInterval) {
        guard isCharging, sparkEnabled, window != nil,
              let fill = barFill, let fillLayer = fill.layer,
              currentPercentage > 0.02 else {
            sparkLayer?.isHidden = true
            return
        }
        let length = isVertical ? fill.bounds.height : fill.bounds.width
        guard length > 12 else {
            sparkLayer?.isHidden = true
            return
        }

        let band = min(max(12, length * 0.3), 64)
        let period: Double = 1.3
        let progress = (t.truncatingRemainder(dividingBy: period)) / period
        let travel = CGFloat(progress)

        // Scintillement électrique : mélange de sinus rapides, stable et toujours dans [0, 1].
        let flicker = Double(abs(sin(t * 23.7)) * 0.6 + abs(sin(t * 41.3)) * 0.4)

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        let gradient = ensureSparkLayer(in: fillLayer)
        gradient.isHidden = false
        gradient.opacity = Float(0.45 + 0.55 * flicker)
        if isVertical {
            gradient.startPoint = CGPoint(x: 0.5, y: 0)
            gradient.endPoint = CGPoint(x: 0.5, y: 1)
            gradient.frame = CGRect(x: 0, y: (length - band) * (1 - travel), width: fill.bounds.width, height: band)
        } else {
            gradient.startPoint = CGPoint(x: 0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1, y: 0.5)
            gradient.frame = CGRect(x: (length - band) * travel, y: 0, width: band, height: fill.bounds.height)
        }
        CATransaction.commit()
    }

    private func ensureSparkLayer(in host: CALayer) -> CAGradientLayer {
        if let sparkLayer { return sparkLayer }
        let gradient = CAGradientLayer()
        gradient.colors = [
            NSColor.white.withAlphaComponent(0).cgColor,
            NSColor.white.withAlphaComponent(0.95).cgColor,
            NSColor.white.withAlphaComponent(0).cgColor
        ]
        gradient.locations = [0, 0.5, 1]
        gradient.cornerRadius = 3
        host.addSublayer(gradient)
        sparkLayer = gradient
        return gradient
    }

    // MARK: - Consommation (érosion + fumée en décharge)

    private func updateSmoke() {
        let active = isDischarging && consumptionEnabled && window != nil && currentPercentage > 0.01
        guard active, let fill = barFill else {
            clearSmoke()
            return
        }
        let edge: CGPoint = isVertical
            ? CGPoint(x: fill.frame.midX, y: fill.frame.maxY)
            : CGPoint(x: fill.frame.maxX, y: fill.frame.midY)

        smokeTick += 1
        if smokeTick % 3 == 0 { spawnPuff(at: edge) }

        let dt: CGFloat = 0.05
        let lifetime: CGFloat = 1.2
        puffs.removeAll { $0.life <= 0 }
        for i in puffs.indices {
            puffs[i].life -= dt / lifetime
            puffs[i].position.x += puffs[i].velocity.dx * dt
            puffs[i].position.y += puffs[i].velocity.dy * dt
        }
        syncPuffLayers()
    }

    private func spawnPuff(at edge: CGPoint) {
        while puffLayers.count < 8 { puffLayers.append(makePuffLayer()) }
        let velocity: CGVector
        if isVertical {
            velocity = CGVector(dx: CGFloat.random(in: -3...3), dy: barPosition == .left ? 10 : -10)
        } else {
            velocity = CGVector(dx: CGFloat.random(in: 6...16), dy: CGFloat.random(in: -2...1.5))
        }
        puffs.append(SmokePuff(position: edge, velocity: velocity, life: 1))
    }

    private func syncPuffLayers() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        for (i, layer) in puffLayers.enumerated() {
            guard i < puffs.count else {
                layer.isHidden = true
                continue
            }
            let puff = puffs[i]
            let life = max(0, puff.life)
            let size = 3 + (1 - life) * 7
            layer.isHidden = false
            layer.bounds = CGRect(x: 0, y: 0, width: size, height: size)
            layer.position = puff.position
            layer.opacity = Float(0.55 * life)
        }
        CATransaction.commit()
    }

    private func clearSmoke() {
        puffs.removeAll()
        smokeTick = 0
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        puffLayers.forEach { $0.isHidden = true }
        CATransaction.commit()
    }

    private func makePuffLayer() -> CALayer {
        let layer = CALayer()
        layer.contents = Self.smokeParticleImage()
        layer.isHidden = true
        self.layer?.addSublayer(layer)
        return layer
    }

    private static func smokeParticleImage() -> CGImage? {
        let size = 16
        guard let ctx = CGContext(
            data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }
        let colors = [
            NSColor.white.withAlphaComponent(1).cgColor,
            NSColor.white.withAlphaComponent(0).cgColor
        ] as CFArray
        if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 1]) {
            let center = CGPoint(x: 8, y: 8)
            ctx.drawRadialGradient(gradient, startCenter: center, startRadius: 0, endCenter: center, endRadius: 8, options: [])
        }
        return ctx.makeImage()
    }

    private var flowWave: CGFloat {
        guard flowEnabled, window != nil else { return 0 }
        let length = isVertical ? bounds.height : bounds.width
        // Mouvement discret, réduit près de 0/100 % pour conserver le niveau réel.
        let amplitude = min(isCharging ? 3 : 2, length * currentPercentage, length * (1 - currentPercentage))
        return sin(flowPhase) * amplitude
    }

    private func applyAnimatedFillFrame(wave: CGFloat) {
        let barT = effectiveBarThickness
        // La ligne reste collée au bord de l'écran ; le texte déborde vers l'intérieur.
        let anchorX: CGFloat = barPosition == .left ? 0 : bounds.width - barT
        let anchorY: CGFloat = barPosition == .top ? bounds.height - barT : 0

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        if isVertical {
            trackLayer?.frame = CGRect(x: anchorX, y: 0, width: barT, height: bounds.height)
        } else {
            trackLayer?.frame = CGRect(x: 0, y: anchorY, width: bounds.width, height: barT)
        }
        CATransaction.commit()

        if isVertical {
            let baseHeight = bounds.height * currentPercentage
            let height = min(max(baseHeight + wave, 0), bounds.height)
            barFill?.frame = NSRect(x: anchorX, y: 0, width: barT, height: height)
        } else {
            let baseWidth = bounds.width * currentPercentage
            let width = min(max(baseWidth + wave, 0), bounds.width)
            barFill?.frame = NSRect(x: 0, y: anchorY, width: width, height: barT)
        }
    }

    func updateBarThickness(_ value: CGFloat) {
        guard barThickness != value else { return }
        barThickness = value
        updateBarFrame()
    }

    func updateBarPosition(_ value: BarPosition) {
        guard barPosition != value else { return }
        barPosition = value
        updateBarFrame()
    }

    func updateShowPercentage(_ show: Bool) {
        guard showPercentageFlag != show else { return }
        showPercentageFlag = show
        updateBarFrame()
    }

    func updateForceShowText(_ force: Bool) {
        guard forceShowText != force else { return }
        forceShowText = force
        updateBarFrame()
    }
}
