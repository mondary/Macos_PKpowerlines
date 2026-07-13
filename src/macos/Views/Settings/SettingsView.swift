import SwiftUI

struct SettingsView: View {
    @State private var selection: SettingsSection? = .powerline

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
                switch selection ?? .powerline {
                case .powerline: PowerlineSettingsView()
                case .menuBar:   MenuBarSettingsView()
                case .about:     AboutSettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 880, minHeight: 560)
    }
}

enum SettingsSection: String, CaseIterable, Identifiable {
    case powerline
    case menuBar
    case about

    var id: String { rawValue }

    var title: String {
        switch self {
        case .powerline: return "Powerline"
        case .menuBar:   return "Menu Bar"
        case .about:     return "À propos"
        }
    }

    var icon: String {
        switch self {
        case .powerline: return "chart.bar.fill"
        case .menuBar:   return "menubar"
        case .about:     return "info.circle"
        }
    }
}
