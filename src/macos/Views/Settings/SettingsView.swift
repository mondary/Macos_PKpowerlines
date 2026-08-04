import SwiftUI

struct SettingsView: View {
    @State private var selection: SettingsSection? = .source

    var body: some View {
        NavigationSplitView {
            List(SettingsSection.allCases, selection: $selection) { section in
                Label(section.title, systemImage: section.icon).tag(section)
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                HStack(spacing: 10) {
                    if let icon = AppIcon.image {
                        Image(nsImage: icon)
                            .resizable()
                            .interpolation(.high)
                            .frame(width: 26, height: 26)
                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    }
                    Text("PKpowerlines")
                        .font(.headline)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.regularMaterial)
            }
            .listStyle(.sidebar)
            .frame(minWidth: 220)
        } detail: {
            Group {
                switch selection ?? .source {
                case .source:     SourceSettingsView()
                case .appearance: AppearanceSettingsView()
                case .colors:     ColorsSettingsView()
                case .position:   PositionSettingsView()
                case .menuBar:    MenuBarSettingsView()
                case .about:      AboutSettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 820, minHeight: 520)
    }
}

enum SettingsSection: String, CaseIterable, Identifiable {
    case source
    case appearance
    case colors
    case position
    case menuBar
    case about

    var id: String { rawValue }

    var title: String {
        switch self {
        case .source:     return "Source"
        case .appearance: return "Apparence"
        case .colors:     return "Couleurs"
        case .position:   return "Position"
        case .menuBar:    return "Menu Bar"
        case .about:      return "À propos"
        }
    }

    var icon: String {
        switch self {
        case .source:     return "dot.radiowaves.left.and.right"
        case .appearance: return "paintbrush"
        case .colors:     return "paintpalette"
        case .position:   return "rectangle.portrait"
        case .menuBar:    return "menubar"
        case .about:      return "info.circle"
        }
    }
}
