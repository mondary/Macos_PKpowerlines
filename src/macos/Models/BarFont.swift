import AppKit

/// Police du pourcentage. Les classiques sont toujours proposées ; toutes les
/// Nerd Fonts installées sur le Mac sont détectées et ajoutées automatiquement.
struct BarFont: Identifiable, Hashable, Codable {
    let id: String
    let displayName: String

    var isNerdFont: Bool { id != Self.systemBold.id && id != Self.systemRegular.id && id.contains("NerdFont") }

    func nsFont(size: CGFloat) -> NSFont {
        switch id {
        case Self.systemBold.id:
            return NSFont.boldSystemFont(ofSize: size)
        case Self.systemRegular.id:
            return NSFont.systemFont(ofSize: size)
        default:
            return NSFont(name: id, size: size) ?? NSFont.systemFont(ofSize: size)
        }
    }

    // MARK: - Classiques

    static let systemBold = BarFont(id: "systemBold", displayName: "Système (gras)")
    static let systemRegular = BarFont(id: "systemRegular", displayName: "Système")

    static let builtIns: [BarFont] = [
        .systemBold,
        .systemRegular,
        BarFont(id: "HelveticaNeue", displayName: "Helvetica Neue"),
        BarFont(id: "Menlo-Regular", displayName: "Menlo"),
        BarFont(id: "SFMono-Regular", displayName: "SF Mono"),
        BarFont(id: "Monaco", displayName: "Monaco"),
        BarFont(id: "Courier", displayName: "Courier"),
        BarFont(id: "AvenirNext-Regular", displayName: "Avenir Next"),
        BarFont(id: "Futura-Medium", displayName: "Futura"),
        BarFont(id: "Optima-Regular", displayName: "Optima"),
        BarFont(id: "Georgia", displayName: "Georgia"),
        BarFont(id: "TrebuchetMS", displayName: "Trebuchet MS"),
        BarFont(id: "Verdana", displayName: "Verdana"),
        BarFont(id: "GillSans", displayName: "Gill Sans"),
        BarFont(id: "Baskerville", displayName: "Baskerville"),
        BarFont(id: "Rockwell-Regular", displayName: "Rockwell")
    ]

    // MARK: - Nerd Fonts installées

    /// Familles « Nerd Font » détectées sur le système, avec leur nom PostScript
    /// régulier pour que `NSFont(name:)` fonctionne à coup sûr.
    static let nerdFonts: [BarFont] = {
        let manager = NSFontManager.shared
        return manager.availableFontFamilies
            .filter { $0.localizedCaseInsensitiveContains("nerd font") }
            .sorted()
            .compactMap { family in
                let members = manager.availableMembers(ofFontFamily: family) ?? []
                let regular = members.first { ($0.count > 1 && ($0[1] as? String) == "Regular") } ?? members.first
                guard let postScript = regular?.first as? String else { return nil }
                return BarFont(id: postScript, displayName: family)
            }
    }()

    /// Classiques + Nerd Fonts, pour les sélecteurs.
    static var all: [BarFont] { builtIns + nerdFonts }

    static func byID(_ id: String) -> BarFont? {
        all.first { $0.id == id }
    }
}
