import SwiftUI

struct CreditsSettingsView: View {
    private struct Credit: Identifiable {
        let id: String
        let icon: String
        let title: String
        let author: String
        let use: String
        let license: String?
        let color: Color
        let url: URL
    }

    private let tools = [
        Credit(
            id: "sparkle",
            icon: "sparkles",
            title: "Sparkle",
            author: "Sparkle project",
            use: "Mises à jour intégrées de l’app macOS.",
            license: "MIT",
            color: .orange,
            url: URL(string: "https://github.com/sparkle-project/Sparkle")!
        )
    ]

    private let inspirations = [
        Credit(
            id: "powerline-android",
            icon: "rectangle.topthird.inset.filled",
            title: "PowerLine: Status bar meters",
            author: "Urbandroid Team · Android",
            use: "Inspiration pour les indicateurs fins et toujours visibles dans la barre d’état.",
            license: nil,
            color: Color(red: 0.12, green: 0.68, blue: 0.48),
            url: URL(string: "https://play.google.com/store/apps/details?id=com.urbandroid.inline")!
        )
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                VStack(spacing: 8) {
                    Image(systemName: "text.book.closed.fill")
                        .font(.system(size: 36, weight: .medium))
                        .foregroundStyle(Color.accentColor)
                    Text("Crédits & inspirations")
                        .font(.system(size: 20, weight: .bold))
                    Text("Les outils utilisés et la référence Android qui a inspiré PKpowerlines.")
                        .font(.system(size: 13)).foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 36).padding(.bottom, 4)

                creditGroup(title: "Outils et dépendances", credits: tools)
                creditGroup(title: "Inspirations", credits: inspirations)

                Text("PKpowerlines est un projet indépendant, sans affiliation avec les auteurs cités.")
                    .font(.caption).foregroundStyle(.secondary)
                    .frame(maxWidth: 480, alignment: .leading)
            }
            .padding(.horizontal, 24).padding(.bottom, 32)
            .frame(maxWidth: .infinity)
        }
    }

    private func creditGroup(title: String, credits: [Credit]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.system(size: 13, weight: .semibold))
            VStack(spacing: 0) {
                ForEach(Array(credits.enumerated()), id: \.element.id) { index, credit in
                    if index > 0 { Divider().padding(.leading, 58) }
                    Link(destination: credit.url) {
                        HStack(spacing: 12) {
                            Image(systemName: credit.icon)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(credit.color)
                                .frame(width: 36, height: 36)
                                .background(credit.color.opacity(0.12), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 6) {
                                    Text(credit.title).font(.system(size: 13, weight: .semibold))
                                    if let license = credit.license {
                                        Text(license).font(.system(size: 9, weight: .medium, design: .monospaced))
                                            .foregroundStyle(.secondary)
                                            .padding(.horizontal, 5).padding(.vertical, 2)
                                            .background(Color.primary.opacity(0.06), in: Capsule())
                                    }
                                }
                                Text(credit.author).font(.system(size: 11, weight: .medium)).foregroundStyle(.secondary)
                                Text(credit.use).font(.system(size: 11)).foregroundStyle(.secondary)
                            }
                            Spacer(minLength: 0)
                            Image(systemName: "arrow.up.right").font(.system(size: 10)).foregroundStyle(.tertiary)
                        }
                        .padding(.horizontal, 14).padding(.vertical, 10)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .frame(maxWidth: 520, alignment: .leading)
    }
}
