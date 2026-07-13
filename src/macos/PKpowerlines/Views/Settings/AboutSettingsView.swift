import SwiftUI

struct AboutSettingsView: View {
    private let appVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "1.7.0"
    private let appBuild = (Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? "1"

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    appIconLarge
                        .padding(.top, 36)
                        .padding(.bottom, 16)

                    Text("PKpowerlines")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.primary)

                    Text("Version \(appVersion) (\(appBuild))")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)

                    Text("Par PK")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .padding(.top, 2)
                        .padding(.bottom, 32)

                    aboutText
                        .frame(maxWidth: 480)
                        .padding(.bottom, 32)
                }
                .frame(maxWidth: .infinity)
            }

            Divider()

            footer
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var appIconLarge: some View {
        Group {
            if let icon = AppIcon.image {
                Image(nsImage: icon)
                    .resizable()
                    .interpolation(.high)
                    .frame(width: 88, height: 88)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 12, y: 8)
            } else {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.accentColor)
                    .frame(width: 88, height: 88)
            }
        }
    }

    private var aboutText: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Salut l'ami,")
                .italic()
                .font(.system(size: 13))

            Text("PKpowerlines est né d'une frustration simple : surveiller la RAM ou la batterie sans encombrer l'écran.")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)

            Text("Une barre fine, toujours visible, personnalisable au pixel près. Couleurs, police, opacité, position, offset — tout est ajustable. Multi-écrans, binaire universel, zero dépendance.")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)

            Text("Construit avec soin pour la communauté Mac, PKpowerlines vise à se sentir chez soi sur ton bureau — discret quand tu n'as pas besoin de lui, présent quand tu le regardes.")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)

            Text("Merci d'en faire partie.")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .padding(.top, 8)

            Text("— PK")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
        }
    }

    private var footer: some View {
        HStack(alignment: .center, spacing: 16) {
            Link(destination: URL(string: "https://github.com/mondary/Macos_PKpowerlines")!) {
                Label("GitHub", systemImage: "network")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Link(destination: URL(string: "https://github.com/mondary/Macos_PKpowerlines/issues")!) {
                Label("Issues", systemImage: "exclamationmark.bubble")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("MIT License")
                .font(.caption)
                .foregroundStyle(.tertiary)
            Text("·")
                .font(.caption)
                .foregroundStyle(.tertiary)
            Text("macOS 13+")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }
}
