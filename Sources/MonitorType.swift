import Foundation

enum MonitorType: String, CaseIterable {
    case ram
    case battery

    var displayName: String {
        switch self {
        case .ram: return "RAM"
        case .battery: return "Batterie"
        }
    }
}
