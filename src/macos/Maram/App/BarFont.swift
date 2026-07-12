import AppKit

enum BarFont: String, CaseIterable, Identifiable, Codable {
    case systemBold
    case systemRegular
    case helveticaNeue
    case menlo
    case sfMono
    case monaco
    case courier

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .systemBold:    return "Système (gras)"
        case .systemRegular: return "Système"
        case .helveticaNeue: return "Helvetica Neue"
        case .menlo:         return "Menlo"
        case .sfMono:        return "SF Mono"
        case .monaco:        return "Monaco"
        case .courier:       return "Courier"
        }
    }

    func nsFont(size: CGFloat) -> NSFont {
        switch self {
        case .systemBold:    return NSFont.boldSystemFont(ofSize: size)
        case .systemRegular: return NSFont.systemFont(ofSize: size)
        case .helveticaNeue: return NSFont(name: "HelveticaNeue", size: size) ?? .systemFont(ofSize: size)
        case .menlo:         return NSFont(name: "Menlo", size: size) ?? .systemFont(ofSize: size)
        case .sfMono:        return NSFont(name: "SFMono-Regular", size: size) ?? .systemFont(ofSize: size)
        case .monaco:        return NSFont(name: "Monaco", size: size) ?? .systemFont(ofSize: size)
        case .courier:       return NSFont(name: "Courier", size: size) ?? .systemFont(ofSize: size)
        }
    }
}
