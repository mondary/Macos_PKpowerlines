import SwiftUI

struct AppearanceSettingsView: View {
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                heightSection
                presetsSection
                shortcutHintSection
            }
            .padding(24)
        }
    }

    private var heightSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hauteur de la barre")
                .font(.headline)

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 12) {
                    Slider(value: $settings.barHeight, in: AppSettings.minHeight...AppSettings.maxHeight)
                    Text("\(Int(settings.barHeight)) px")
                        .monospacedDigit()
                        .frame(width: 56, alignment: .trailing)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 6) {
                    Text("\(Int(AppSettings.minHeight)) px")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                    Spacer()
                    Text("\(Int(AppSettings.maxHeight)) px")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            Text("La hauteur s'applique en direct sur tous les écrans.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var presetsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Préréglages")
                .font(.headline)

            HStack(spacing: 10) {
                presetButton("Fin", height: 8)
                presetButton("Normal", height: 12)
                presetButton("Épais", height: 20)
                Spacer(minLength: 0)
            }
        }
    }

    private func presetButton(_ title: String, height: CGFloat) -> some View {
        let isActive = abs(settings.barHeight - height) < 0.01
        return Button {
            settings.barHeight = height
        } label: {
            VStack(spacing: 4) {
                Text(title).font(.caption.weight(.medium))
                Text("\(Int(height)) px")
                    .font(.caption2)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            .frame(width: 86, height: 48)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(isActive ? Color.accentColor.opacity(0.18) : Color(NSColor.controlBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(isActive ? Color.accentColor : Color.secondary.opacity(0.25), lineWidth: isActive ? 1.5 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var shortcutHintSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Raccourcis")
                .font(.headline)
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
