import SwiftUI

struct LibrarySettingsView: View {
    private struct Project: Identifiable {
        let id: String
        let title: String
        let kind: String
        let description: String
        let iconAsset: String
        let screenshot: String?
        let tint: NSColor
        var url: URL { URL(string: "https://github.com/mondary/\(id)")! }
    }

    private enum Tint {
        static let powerlines = NSColor(hex: "#10B981")!
        static let monitor = NSColor(hex: "#0EA5E9")!
        static let archives = NSColor(hex: "#8B5CF6")!
        static let windows = NSColor(hex: "#F97316")!
        static let cleanup = NSColor(hex: "#EC4899")!
        static let mail = NSColor(hex: "#EA4335")!
        static let shortcuts = NSColor(hex: "#F59E0B")!
    }

    private let projects: [Project] = [
        Project(id: "Macos_PKpowerlines", title: "PKpowerlines", kind: "app macOS", description: "Une powerline multi-écrans qui affiche RAM, CPU, réseau ou batterie en temps réel.", iconAsset: "PKpowerlines", screenshot: "PKpowerlines", tint: Tint.powerlines),
        Project(id: "PKmonitor", title: "PKMonitor", kind: "app macOS", description: "CPU, GPU, RAM, réseau et disque dans la menu bar, avec sparklines et jauges.", iconAsset: "PKmonitor", screenshot: "PKmonitor", tint: Tint.monitor),
        Project(id: "Macos_PKarchives", title: "PKarchives", kind: "app macOS", description: "Archive ton Bureau vers Google Drive avec rclone, interface native ou CLI/TUI.", iconAsset: "PKarchives", screenshot: "PKarchives", tint: Tint.archives),
        Project(id: "PKwindowsManagement", title: "PKwindowsManagement", kind: "app macOS", description: "Gère tes fenêtres au clavier et lance tes apps rapidement depuis la menu bar.", iconAsset: "PKwindowsManagement", screenshot: nil, tint: Tint.windows),
        Project(id: "PKmac-cleanup", title: "LaunchPad", kind: "app macOS", description: "Scan et audit des user agents et daemons système avec analyse de sécurité locale.", iconAsset: "PKmac-cleanup", screenshot: nil, tint: Tint.cleanup),
        Project(id: "Chrome_SimpleGMAIL", title: "PKMail", kind: "Chrome · macOS · Windows · Linux", description: "Client mail IMAP immersif, interface HTML vanilla et workflows façon Gmail.", iconAsset: "PKMail", screenshot: nil, tint: Tint.mail),
        Project(id: "Chrome_PKshortcuts", title: "PK Chrome Shortcuts", kind: "extension Chrome", description: "Contrôle onglets, navigation et split view au clavier.", iconAsset: "PKshortcuts", screenshot: nil, tint: Tint.shortcuts)
    ]

    private var featured: Project { projects.first { $0.id == "Macos_PKpowerlines" }! }
    private var gridProjects: [Project] { projects.filter { $0.id != "Macos_PKpowerlines" } }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                SettingsHeader(title: "Bibliothèque de projets", subtitle: "Découvre les autres outils et projets PK.", icon: "square.grid.2x2")
                featuredCard(featured)
                Text("Plus de projets").font(.system(size: 18, weight: .bold, design: .rounded))
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                    ForEach(gridProjects) { project in
                        projectCard(project)
                    }
                }
                Link(destination: ProjectLinks.githubProfile) {
                    Label("Voir tous les dépôts sur GitHub", systemImage: "arrow.up.right.square")
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 6)
            }
            .padding(28)
        }
    }

    private func featuredCard(_ project: Project) -> some View {
        Link(destination: project.url) {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        ProjectIconView(name: project.iconAsset)
                            .frame(width: 56, height: 56)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .shadow(color: .black.opacity(0.18), radius: 5, y: 2)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(project.title).font(.system(size: 24, weight: .bold, design: .rounded))
                            Text(project.kind.uppercased()).font(.system(size: 10, weight: .bold)).foregroundStyle(Color(nsColor: project.tint))
                        }
                    }
                    Text(project.description)
                        .font(.system(size: 13)).foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(3)
                    Label("Star sur GitHub", systemImage: "star.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12).padding(.vertical, 7)
                        .background(Color.accentColor, in: Capsule())
                }
                .padding(22)
                .frame(maxWidth: 340, alignment: .topLeading)
                if let image = project.screenshot.flatMap(ProjectAssets.screenshot) {
                    GeometryReader { geo in
                        Image(nsImage: image)
                            .resizable().interpolation(.high)
                            .scaledToFill()
                            .frame(width: geo.size.width, height: geo.size.height)
                            .clipped()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay(alignment: .leading) {
                        LinearGradient(colors: [Color(nsColor: .controlBackgroundColor), .clear], startPoint: .leading, endPoint: .trailing)
                            .frame(width: 60)
                    }
                }
            }
            .frame(height: 210)
            .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color(nsColor: .separatorColor).opacity(0.55), lineWidth: 0.5))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func projectCard(_ project: Project) -> some View {
        Link(destination: project.url) {
            VStack(alignment: .leading, spacing: 0) {
                Group {
                    if let shot = project.screenshot, let image = ProjectAssets.screenshot(shot) {
                        Image(nsImage: image)
                            .resizable().interpolation(.high)
                            .scaledToFill()
                            .frame(width: 300, height: 150)
                            .clipped()
                    } else {
                        ZStack {
                            LinearGradient(colors: [Color(nsColor: project.tint).opacity(0.75), Color(nsColor: project.tint).opacity(0.35)],
                                           startPoint: .topLeading, endPoint: .bottomTrailing)
                            ProjectIconView(name: project.iconAsset)
                                .frame(width: 74, height: 74)
                                .shadow(color: .black.opacity(0.25), radius: 8, y: 3)
                        }
                    }
                }
                .frame(height: 150)
                .frame(maxWidth: .infinity)
                .clipped()
                .overlay(alignment: .topLeading) {
                    Text(project.kind.uppercased())
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding(10)
                }
                HStack(alignment: .top, spacing: 10) {
                    ProjectIconView(name: project.iconAsset)
                        .frame(width: 30, height: 30)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    VStack(alignment: .leading, spacing: 3) {
                        Text(project.title).font(.system(size: 14, weight: .semibold))
                        Text(project.description).font(.system(size: 11)).foregroundStyle(.secondary).lineLimit(2)
                    }
                    Spacer(minLength: 8)
                    Image(systemName: "arrow.up.right").font(.caption).foregroundStyle(.tertiary)
                }
                .padding(14)
            }
            .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).stroke(Color(nsColor: .separatorColor).opacity(0.55), lineWidth: 0.5))
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
