import SwiftUI

struct SupportSettingsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                header
                    .padding(.top, 36)
                    .padding(.bottom, 24)

                VStack(spacing: 16) {
                    coffeeCard
                    linksCard
                }
                .frame(maxWidth: 480)
                .padding(.bottom, 32)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "heart.fill")
                .font(.system(size: 36))
                .foregroundStyle(.red)

            Text("Soutenir PKpowerlines")
                .font(.system(size: 20, weight: .bold))

            Text("Si l'app te plaît, pense à soutenir son développement.")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var coffeeCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "cup.and.saucer.fill")
                .font(.system(size: 22))
                .foregroundStyle(.orange)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text("Offrez-moi un café")
                    .font(.system(size: 14, weight: .semibold))
                Text("Soutiens le développeur avec un café")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Link(destination: ProjectLinks.koFi) {
                Text("Faire un don")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(Color.orange)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var linksCard: some View {
        VStack(spacing: 0) {
            linkRow(icon: "network", title: "GitHub", subtitle: "Code source et releases", url: ProjectLinks.github)
            Divider().padding(.leading, 52)
            linkRow(icon: "exclamationmark.bubble", title: "Signaler un problème", subtitle: "Bugs, idées, retours", url: ProjectLinks.issues)
            Divider().padding(.leading, 52)
            linkRow(icon: "person.crop.circle", title: "PK sur GitHub", subtitle: "Le reste de la collection de projets", url: ProjectLinks.githubProfile)
        }
        .background(Color(NSColor.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func linkRow(icon: String, title: String, subtitle: String, url: URL) -> some View {
        Link(destination: url) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
                    .frame(width: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 13, weight: .medium))
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 11))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
