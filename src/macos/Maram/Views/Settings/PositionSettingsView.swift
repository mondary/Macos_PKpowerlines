import SwiftUI

struct PositionSettingsView: View {
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                positionSection
                screenPreviewSection
                shortcutHintSection
            }
            .padding(24)
        }
    }

    private var positionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Position de la barre")
                .font(.headline)

            Picker("Position", selection: $settings.barPosition) {
                ForEach(BarPosition.allCases) { p in
                    Label(p.displayName, systemImage: p.icon).tag(p)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .frame(maxWidth: 360)

            Text("La barre s'aligne en haut ou en bas de la zone utile de chaque écran (menu bar et Dock exclus).")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var screenPreviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Aperçu")
                .font(.headline)

            GeometryReader { geo in
                let h = max(8.0, min(28.0, geo.size.height * 0.18))
                ZStack(alignment: settings.barPosition == .top ? .top : .bottom) {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(NSColor.windowBackgroundColor))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(Color.secondary.opacity(0.25), lineWidth: 1)
                        )
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(settings.monitorType == .ram ? settings.ramColor : settings.batteryColor)
                        .frame(width: geo.size.width * 0.62, height: h)
                        .padding(8)
                }
            }
            .frame(height: 180)
        }
    }

    private var shortcutHintSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Raccourcis").font(.headline)
            HStack(spacing: 16) {
                Label("Fin  ⌘1", systemImage: "1.circle")
                Label("Normal  ⌘2", systemImage: "2.circle")
                Label("Épais  ⌘3", systemImage: "3.circle")
                Label("Réglages  ⌘,", systemImage: "gearshape")
                Spacer()
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }
}
