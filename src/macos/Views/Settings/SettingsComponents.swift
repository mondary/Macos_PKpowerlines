import AppKit
import SwiftUI

enum ProjectLinks {
    static let github = URL(string: "https://github.com/mondary/Macos_PKpowerlines")!
    static let issues = URL(string: "https://github.com/mondary/Macos_PKpowerlines/issues")!
    static let githubProfile = URL(string: "https://github.com/mondary")!
    static let koFi = URL(string: "https://ko-fi.com/pouark")!
}

struct SettingsHeader: View {
    let title: String
    let subtitle: String
    var icon: String = "gearshape"

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 10) {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.accentColor)
                        .frame(width: 34, height: 34)
                        .background(Color.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 9, style: .continuous))
                    Text(title).font(.system(size: 28, weight: .bold, design: .rounded))
                }
                Text(subtitle).font(.system(size: 13)).foregroundStyle(.secondary)
                    .padding(.leading, 44)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 4)
    }
}

enum ProjectAssets {
    static func icon(_ name: String) -> NSImage? {
        NSImage(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: name, ofType: "png", inDirectory: "ProjectIcons") ?? ""))
    }

    static func screenshot(_ name: String) -> NSImage? {
        NSImage(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: name, ofType: "png", inDirectory: "ProjectScreenshots") ?? ""))
    }
}

struct ProjectIconView: View {
    let name: String

    var body: some View {
        if let image = ProjectAssets.icon(name) {
            Image(nsImage: image).resizable().interpolation(.high).scaledToFit()
        } else if let fallback = AppIcon.image {
            Image(nsImage: fallback).resizable().interpolation(.high).scaledToFit()
        } else {
            Color.gray.opacity(0.3)
        }
    }
}

struct PageHeaderModifier: ViewModifier {
    let title: String
    let subtitle: String
    let icon: String

    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            SettingsHeader(title: title, subtitle: subtitle, icon: icon)
                .padding(.horizontal, 28)
                .padding(.top, 24)
                .padding(.bottom, 4)
            content
        }
    }
}

extension View {
    func pageHeader(_ title: String, _ subtitle: String, icon: String) -> some View {
        modifier(PageHeaderModifier(title: title, subtitle: subtitle, icon: icon))
    }
}
