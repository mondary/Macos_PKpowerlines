import AppKit

enum BarFont: String, CaseIterable, Identifiable, Codable {
    case systemBold
    case systemRegular
    case helveticaNeue
    case menlo
    case sfMono
    case monaco
    case courier
    case avenirNext
    case futura
    case optima
    case georgia
    case trebuchet
    case verdana
    case gillSans
    case baskerville
    case rockwell

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
        case .avenirNext:    return "Avenir Next"
        case .futura:        return "Futura"
        case .optima:        return "Optima"
        case .georgia:       return "Georgia"
        case .trebuchet:     return "Trebuchet MS"
        case .verdana:       return "Verdana"
        case .gillSans:      return "Gill Sans"
        case .baskerville:   return "Baskerville"
        case .rockwell:      return "Rockwell"
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
        case .avenirNext:    return NSFont(name: "AvenirNext-Regular", size: size) ?? .systemFont(ofSize: size)
        case .futura:        return NSFont(name: "Futura-Medium", size: size) ?? .systemFont(ofSize: size)
        case .optima:        return NSFont(name: "Optima-Regular", size: size) ?? .systemFont(ofSize: size)
        case .georgia:       return NSFont(name: "Georgia", size: size) ?? .systemFont(ofSize: size)
        case .trebuchet:     return NSFont(name: "TrebuchetMS", size: size) ?? .systemFont(ofSize: size)
        case .verdana:       return NSFont(name: "Verdana", size: size) ?? .systemFont(ofSize: size)
        case .gillSans:      return NSFont(name: "GillSans", size: size) ?? .systemFont(ofSize: size)
        case .baskerville:   return NSFont(name: "Baskerville", size: size) ?? .systemFont(ofSize: size)
        case .rockwell:      return NSFont(name: "Rockwell-Regular", size: size) ?? .systemFont(ofSize: size)
        }
    }
}
