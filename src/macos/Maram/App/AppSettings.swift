import Combine
import CoreGraphics
import Foundation

final class AppSettings: ObservableObject {
    private enum Keys {
        static let monitorType = "monitorType"
        static let barHeight = "barHeight"
    }

    @Published var monitorType: MonitorType {
        didSet { defaults.set(monitorType.rawValue, forKey: Keys.monitorType) }
    }

    @Published var barHeight: CGFloat {
        didSet { defaults.set(Double(barHeight), forKey: Keys.barHeight) }
    }

    static let defaultHeight: CGFloat = 12
    static let minHeight: CGFloat = 4
    static let maxHeight: CGFloat = 40

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let monitorRaw = defaults.string(forKey: Keys.monitorType) ?? MonitorType.ram.rawValue
        self.monitorType = MonitorType(rawValue: monitorRaw) ?? .ram
        let storedHeight = defaults.object(forKey: Keys.barHeight) as? Double
        self.barHeight = CGFloat(storedHeight ?? Self.defaultHeight)
    }
}
