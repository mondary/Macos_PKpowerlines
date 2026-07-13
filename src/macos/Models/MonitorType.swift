import Foundation

enum MonitorType: String, CaseIterable, Identifiable {
    case ram
    case battery

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .ram: return "RAM"
        case .battery: return "Batterie"
        }
    }

    var icon: String {
        switch self {
        case .ram: return "memorychip"
        case .battery: return "battery.100"
        }
    }

    var description: String {
        switch self {
        case .ram: return "Mémoire vive active et câblée (wired)."
        case .battery: return "Niveau de charge et état de la batterie."
        }
    }
}
