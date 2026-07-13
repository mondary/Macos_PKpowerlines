import Foundation

enum MonitorType: String, CaseIterable, Identifiable {
    case ram
    case battery
    case cpu
    case network

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .ram: return "RAM"
        case .battery: return "Batterie"
        case .cpu: return "CPU"
        case .network: return "Réseau"
        }
    }

    var icon: String {
        switch self {
        case .ram: return "memorychip"
        case .battery: return "battery.100"
        case .cpu: return "cpu"
        case .network: return "network"
        }
    }

    var description: String {
        switch self {
        case .ram: return "Mémoire vive active et câblée (wired)."
        case .battery: return "Niveau de charge et état de la batterie."
        case .cpu: return "Charge CPU globale (user + système + nice)."
        case .network: return "Débit cumulé descendant + montant, toutes interfaces."
        }
    }
}
