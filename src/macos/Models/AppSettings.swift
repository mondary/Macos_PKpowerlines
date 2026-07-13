import Combine
import CoreGraphics
import Foundation
import SwiftUI

final class AppSettings: ObservableObject {
    private enum Keys {
        static let monitorType = "monitorType"
        static let updateInterval = "updateInterval"
        static let barHeight = "barHeight"
        static let barOpacity = "barOpacity"
        static let barPosition = "barPosition"
        static let barOffset = "barOffset"
        static let barFont = "barFont"
        static let ramColor = "ramColor"
        static let batteryColor = "batteryColor"
        static let batteryLowColor = "batteryLowColor"
        static let batteryLowThreshold = "batteryLowThreshold"
    }

    @Published var monitorType: MonitorType { didSet { defaults.set(monitorType.rawValue, forKey: Keys.monitorType) } }
    @Published var updateInterval: Double { didSet { defaults.set(updateInterval, forKey: Keys.updateInterval) } }
    @Published var barHeight: CGFloat { didSet { defaults.set(Double(barHeight), forKey: Keys.barHeight) } }
    @Published var barOpacity: Double { didSet { defaults.set(barOpacity, forKey: Keys.barOpacity) } }
    @Published var barPosition: BarPosition { didSet { defaults.set(barPosition.rawValue, forKey: Keys.barPosition) } }
    @Published var barOffset: CGFloat { didSet { defaults.set(Double(barOffset), forKey: Keys.barOffset) } }
    @Published var barFont: BarFont { didSet { defaults.set(barFont.rawValue, forKey: Keys.barFont) } }
    @Published var ramColorHex: String { didSet { defaults.set(ramColorHex, forKey: Keys.ramColor) } }
    @Published var batteryColorHex: String { didSet { defaults.set(batteryColorHex, forKey: Keys.batteryColor) } }
    @Published var batteryLowColorHex: String { didSet { defaults.set(batteryLowColorHex, forKey: Keys.batteryLowColor) } }
    @Published var batteryLowThreshold: Int { didSet { defaults.set(batteryLowThreshold, forKey: Keys.batteryLowThreshold) } }

    static let defaultHeight: CGFloat = 9
    static let minHeight: CGFloat = 4
    static let maxHeight: CGFloat = 40
    static let defaultOpacity: Double = 0.5
    static let minOpacity: Double = 0.2
    static let maxOpacity: Double = 1.0
    static let minInterval: Double = 1
    static let maxInterval: Double = 10
    static let minOffset: CGFloat = -40
    static let maxOffset: CGFloat = 400
    static let menuBarHeight: CGFloat = 24

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let monitorRaw = defaults.string(forKey: Keys.monitorType) ?? MonitorType.battery.rawValue
        self.monitorType = MonitorType(rawValue: monitorRaw) ?? .battery
        self.updateInterval = defaults.object(forKey: Keys.updateInterval) as? Double ?? 2.0
        let storedHeight = defaults.object(forKey: Keys.barHeight) as? Double
        self.barHeight = CGFloat(storedHeight ?? Self.defaultHeight)
        let storedOpacity = defaults.object(forKey: Keys.barOpacity) as? Double
        self.barOpacity = storedOpacity ?? Self.defaultOpacity
        let posRaw = defaults.string(forKey: Keys.barPosition) ?? BarPosition.top.rawValue
        self.barPosition = BarPosition(rawValue: posRaw) ?? .top
        let storedOffset = defaults.object(forKey: Keys.barOffset) as? Double
        self.barOffset = CGFloat(storedOffset ?? 0)
        let fontRaw = defaults.string(forKey: Keys.barFont) ?? BarFont.systemBold.rawValue
        self.barFont = BarFont(rawValue: fontRaw) ?? .systemBold
        self.ramColorHex = defaults.string(forKey: Keys.ramColor) ?? "#FF3B30"
        self.batteryColorHex = defaults.string(forKey: Keys.batteryColor) ?? "#34C759"
        self.batteryLowColorHex = defaults.string(forKey: Keys.batteryLowColor) ?? "#FF3B30"
        self.batteryLowThreshold = (defaults.object(forKey: Keys.batteryLowThreshold) as? Int) ?? 20
    }

    var ramColor: Color { Color(hex: ramColorHex) }
    var batteryColor: Color { Color(hex: batteryColorHex) }
    var batteryLowColor: Color { Color(hex: batteryLowColorHex) }
    var chargingColor: Color { Color(hex: "#007AFF") }
}
