import SwiftUI

struct SettingsView: View {
    @State private var selection: SettingsSection? = .general

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
                    Text("Maram")
                        .font(.headline)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.regularMaterial)
            }
            .listStyle(.sidebar)
            .frame(minWidth: 200)
        } detail: {
            Group {
                switch selection ?? .general {
                case .general:    GeneralSettingsView()
                case .appearance: AppearanceSettingsView()
                case .position:   PositionSettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 640, minHeight: 420)
    }
}

enum SettingsSection: String, CaseIterable, Identifiable {
    case general
    case appearance
    case position

    var id: String { rawValue }

    var title: String {
        switch self {
        case .general:    return "Général"
        case .appearance: return "Apparence"
        case .position:   return "Position"
        }
    }

    var icon: String {
        switch self {
        case .general:    return "gearshape"
        case .appearance: return "paintbrush"
        case .position:   return "rectangle.dashed"
        }
    }
}
