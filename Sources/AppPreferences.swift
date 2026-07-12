import Foundation
import CoreGraphics

enum AppPreferences {
    private static let monitorKey = "monitorType"
    private static let heightKey = "barHeight"

    static let defaultHeight: CGFloat = 12
    static let minHeight: CGFloat = 4
    static let maxHeight: CGFloat = 40

    static var monitorType: MonitorType {
        get {
            let raw = UserDefaults.standard.string(forKey: monitorKey) ?? MonitorType.ram.rawValue
            return MonitorType(rawValue: raw) ?? .ram
        }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: monitorKey) }
    }

    static var barHeight: CGFloat {
        get {
            let v = UserDefaults.standard.double(forKey: heightKey)
            if v == 0 { return defaultHeight }
            return CGFloat(v)
        }
        set { UserDefaults.standard.set(Double(newValue), forKey: heightKey) }
    }
}
