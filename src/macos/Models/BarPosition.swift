import Foundation

enum BarPosition: String, CaseIterable, Identifiable, Codable {
    case top
    case bottom
    case left
    case right

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .top: return "Haut"
        case .bottom: return "Bas"
        case .left: return "Gauche"
        case .right: return "Droite"
        }
    }

    var icon: String {
        switch self {
        case .top: return "arrow.up.to.line"
        case .bottom: return "arrow.down.to.line"
        case .left: return "arrow.left.to.line"
        case .right: return "arrow.right.to.line"
        }
    }

    /// `true` pour les bords verticaux (gauche/droite) — la barre est alors dessinée verticalement.
    var isVertical: Bool {
        switch self {
        case .left, .right: return true
        case .top, .bottom: return false
        }
    }
}
