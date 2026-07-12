import AppKit

protocol SettingsDelegate: AnyObject {
    func settingsDidChange()
}

class SettingsWindowController: NSWindowController, NSWindowDelegate {
    weak var delegate: SettingsDelegate?

    private var monitorSegmented: NSSegmentedControl!
    private var heightSlider: NSSlider!
    private var heightLabel: NSTextField!

    init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 340, height: 200),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Maram — Réglages"
        window.center()
        window.isReleasedWhenClosed = false
        super.init(window: window)
        window.delegate = self
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        guard let contentView = window?.contentView else { return }

        let monitorTitle = NSTextField(labelWithString: "Afficher :")
        monitorTitle.font = NSFont.boldSystemFont(ofSize: 12)

        monitorSegmented = NSSegmentedControl(
            labels: MonitorType.allCases.map { $0.displayName },
            trackingMode: .selectOne,
            target: self,
            action: #selector(monitorChanged)
        )

        heightLabel = NSTextField(labelWithString: heightText(AppPreferences.barHeight))
        heightLabel.font = NSFont.boldSystemFont(ofSize: 12)

        heightSlider = NSSlider(
            value: Double(AppPreferences.barHeight),
            minValue: Double(AppPreferences.minHeight),
            maxValue: Double(AppPreferences.maxHeight),
            target: self,
            action: #selector(heightChanged)
        )

        [monitorTitle, monitorSegmented, heightLabel, heightSlider].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            monitorTitle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            monitorTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            monitorSegmented.topAnchor.constraint(equalTo: monitorTitle.bottomAnchor, constant: 8),
            monitorSegmented.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            monitorSegmented.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            heightLabel.topAnchor.constraint(equalTo: monitorSegmented.bottomAnchor, constant: 24),
            heightLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            heightSlider.topAnchor.constraint(equalTo: heightLabel.bottomAnchor, constant: 8),
            heightSlider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            heightSlider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
        ])

        monitorSegmented.selectedSegment = MonitorType.allCases.firstIndex(of: AppPreferences.monitorType) ?? 0
    }

    private func heightText(_ h: CGFloat) -> String {
        return "Hauteur : \(Int(h))px"
    }

    @objc private func monitorChanged() {
        let idx = monitorSegmented.selectedSegment
        if idx >= 0, idx < MonitorType.allCases.count {
            AppPreferences.monitorType = MonitorType.allCases[idx]
            delegate?.settingsDidChange()
        }
    }

    @objc private func heightChanged() {
        let h = CGFloat(heightSlider.doubleValue.rounded())
        AppPreferences.barHeight = h
        heightLabel.stringValue = heightText(h)
        delegate?.settingsDidChange()
    }

    func refreshUI() {
        monitorSegmented.selectedSegment = MonitorType.allCases.firstIndex(of: AppPreferences.monitorType) ?? 0
        heightSlider.doubleValue = Double(AppPreferences.barHeight)
        heightLabel.stringValue = heightText(AppPreferences.barHeight)
    }
}
