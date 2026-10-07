import SwiftUI

struct AboutSettingsView: View {
    @AppStorage("updateChannel") private var updateChannel = "stable"
    @ObservedObject private var updater = UpdaterManager.shared
    private var isDevBuild: Bool {
        (Bundle.main.object(forInfoDictionaryKey: "PKpowerlinesBuildChannel") as? String) == "dev"
    }
    private let appVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "dev"
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

                    Text("Version installée \(appVersion) (\(appBuild))")
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
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

            updateSection
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)

            Divider()

            footer
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var updateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mises à jour")
                .font(.headline)
            HStack(spacing: 10) {
                versionColumn(title: "Stable", value: updater.latestStableVersion ?? "Non publiée", status: updater.versionStatus(for: "stable"))
                versionColumn(title: "Dev", value: updater.latestDevVersion ?? "Non publiée", status: updater.versionStatus(for: "dev"))
            }
            Picker("Canal", selection: Binding(
                get: { isDevBuild ? "dev" : updateChannel },
                set: {
                    if !isDevBuild {
                        updateChannel = $0
                        updater.updateChannelChanged(to: $0)
                    }
                }
            )) {
                Text("Stable").tag("stable")
                Text("Dev").tag("dev")
            }
            .pickerStyle(.segmented)
            .disabled(isDevBuild)
            Button {
                updater.refreshAvailableVersions()
                updater.checkForUpdates()
            } label: {
                Label(updateButtonTitle, systemImage: updater.availableUpdateVersion == nil ? "arrow.triangle.2.circlepath" : "arrow.down.circle.fill")
            }
            .buttonStyle(.borderedProminent)
            .disabled(!updater.canCheckForUpdates)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.primary.opacity(0.025)))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.primary.opacity(0.08), lineWidth: 1))
    }

    private var updateButtonTitle: String {
        guard let available = updater.availableUpdateVersion else { return "Rechercher les mises à jour…" }
        return "Installer \(available)"
    }

    private func versionColumn(title: String, value: String, status: PowerlinesChannelVersionStatus) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title).font(.system(size: 10, weight: .semibold)).foregroundStyle(.secondary)
            Text(value).font(.system(size: 14, weight: .semibold, design: .monospaced)).lineLimit(1).minimumScaleFactor(0.75).help(value)
            Label(status.title, systemImage: status.symbol)
                .font(.system(size: 10, weight: .medium)).foregroundStyle(status.color).lineLimit(1).minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, alignment: .leading).padding(10)
        .background(Color.primary.opacity(0.045), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
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
            Link(destination: ProjectLinks.koFi) {
                HStack(spacing: 4) {
                    if let logo = AppIcon.kofiLogo {
                        Image(nsImage: logo).resizable().frame(width: 12, height: 12)
                    }
                    Text("Soutenir sur Ko-fi")
                }
                .font(.caption)
                .foregroundStyle(Color(red: 1, green: 0.37, blue: 0.36))
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
