import SwiftUI

struct SettingsView: View {
    @State private var selection: SettingsSection? = .source
    @State private var searchText = ""
    @ObservedObject private var updater = UpdaterManager.shared

    private var filteredSections: [SettingsSection] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return SettingsSection.allCases }
        return SettingsSection.allCases.filter { $0.keywords.contains(query) }
    }

    private var groupedSections: [(String, [SettingsSection])] {
        let grouped = Dictionary(grouping: filteredSections, by: \.category)
        return ["POWERLINE", "PK PROJECTS"].compactMap { key in
            guard let values = grouped[key], !values.isEmpty else { return nil }
            return (key, values)
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            sidebar
            Divider()
            Group {
                switch selection ?? .source {
                case .source:     SourceSettingsView().pageHeader("Source", "Choisis ce que la barre mesure et à quelle fréquence.", icon: "dot.radiowaves.left.and.right")
                case .appearance: AppearanceSettingsView().pageHeader("Apparence", "Hauteur, opacité et police du pourcentage.", icon: "paintbrush")
                case .colors:     ColorsSettingsView().pageHeader("Couleurs", "La couleur de chaque source, seuil batterie compris.", icon: "paintpalette")
                case .position:   PositionSettingsView().pageHeader("Position", "Bord de l'écran, offset au pixel et préréglages.", icon: "rectangle.portrait")
                case .menuBar:    MenuBarSettingsView().pageHeader("Menu Bar", "Aère la menu bar de macOS en ajustant son espacement caché.", icon: "menubar.rectangle")
                case .library:    LibrarySettingsView()
                case .support:    SupportSettingsView()
                case .about:      AboutSettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .frame(minWidth: 980, minHeight: 640)
        .onAppear { updater.refreshAvailableVersions() }
    }

    private var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "dev"
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                if let icon = AppIcon.image {
                    Image(nsImage: icon)
                        .resizable().interpolation(.high).scaledToFit()
                        .frame(width: 34, height: 34)
                        .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("PKpowerlines").font(.headline)
                    Text("Powerline macOS").font(.caption).foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 22)
            .padding(.bottom, 18)

            Text("RÉGLAGES")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.tertiary)
                .padding(.horizontal, 20)
                .padding(.bottom, 8)

            HStack(spacing: 7) {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField("Rechercher", text: $searchText)
                    .textFieldStyle(.plain)
                    .onSubmit {
                        if let first = filteredSections.first { selection = first }
                    }
            }
            .padding(.horizontal, 10)
            .frame(height: 30)
            .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 7))
            .padding(.horizontal, 12)
            .padding(.bottom, 12)

            VStack(spacing: 3) {
                ForEach(groupedSections, id: \.0) { group, sections in
                    Text(group).font(.system(size: 9, weight: .bold)).foregroundStyle(.tertiary)
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20).padding(.top, 8)
                    ForEach(sections) { section in
                        Button {
                            selection = section
                        } label: {
                            HStack(spacing: 11) {
                                Image(systemName: section.icon)
                                    .font(.system(size: 14, weight: .medium))
                                    .frame(width: 20)
                                Text(section.title)
                                    .font(.system(size: 13, weight: selection == section ? .semibold : .regular))
                                Spacer()
                            }
                            .foregroundStyle(selection == section ? .primary : .secondary)
                            .padding(.horizontal, 12)
                            .frame(height: 34)
                            .background(selection == section ? Color.accentColor.opacity(0.13) : .clear,
                                        in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 10)
                    }
                }
            }

            Spacer()

            HStack(spacing: 5) {
                Text("PKpowerlines \(version)")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(.tertiary).lineLimit(1).minimumScaleFactor(0.75)
                if let available = updater.availableUpdateVersion {
                    Button { updater.checkForUpdates() } label: {
                        Label(available, systemImage: "arrow.down.circle.fill")
                            .font(.system(size: 9, weight: .semibold, design: .monospaced)).lineLimit(1)
                    }
                    .buttonStyle(.plain).foregroundStyle(Color.accentColor)
                    .help("Installer la version \(available)")
                }
            }
            .padding(.horizontal, 14).padding(.bottom, 18)
        }
        .frame(width: 220)
        .background(.regularMaterial)
    }
}

enum SettingsSection: String, CaseIterable, Identifiable {
    case source
    case appearance
    case colors
    case position
    case menuBar
    case library
    case support
    case about

    var id: String { rawValue }

    var title: String {
        switch self {
        case .source:     return "Source"
        case .appearance: return "Apparence"
        case .colors:     return "Couleurs"
        case .position:   return "Position"
        case .menuBar:    return "Menu Bar"
        case .library:    return "Bibliothèque"
        case .support:    return "Aide & don"
        case .about:      return "À propos"
        }
    }

    var icon: String {
        switch self {
        case .source:     return "dot.radiowaves.left.and.right"
        case .appearance: return "paintbrush"
        case .colors:     return "paintpalette"
        case .position:   return "rectangle.portrait"
        case .menuBar:    return "menubar.rectangle"
        case .library:    return "square.grid.2x2"
        case .support:    return "heart"
        case .about:      return "info.circle"
        }
    }

    var category: String {
        switch self {
        case .library, .support, .about: return "PK PROJECTS"
        default:                         return "POWERLINE"
        }
    }

    var keywords: String {
        "\(rawValue) \(title) \(category) batterie ram cpu réseau position hauteur police don café projets".lowercased()
    }
}
