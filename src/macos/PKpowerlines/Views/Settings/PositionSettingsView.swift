import SwiftUI

struct PositionSettingsView: View {
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                positionSection
                offsetSection
                quickPresetsSection
                screenPreviewSection
                shortcutHintSection
            }
            .padding(24)
        }
    }

    private var positionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Côté de l'écran")
                .font(.headline)

            Picker("Position", selection: $settings.barPosition) {
                ForEach(BarPosition.allCases) { p in
                    Label(p.displayName, systemImage: p.icon).tag(p)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .frame(maxWidth: 360)

            Text("L'ancre se fait sur le bord brut de l'écran (menu bar et Dock inclus), pas sur la zone utile. L'offset ci-dessous permet de descendre ou monter la barre au pixel près.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var offsetSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Offset vertical")
                .font(.headline)

            HStack(spacing: 12) {
                Slider(value: $settings.barOffset, in: AppSettings.minOffset...AppSettings.maxOffset)
                Stepper(value: $settings.barOffset, in: AppSettings.minOffset...AppSettings.maxOffset, step: 1) {
                    Text("\(Int(settings.barOffset)) px")
                        .monospacedDigit()
                        .frame(width: 72, alignment: .trailing)
                        .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 6) {
                Text("\(Int(AppSettings.minOffset)) px")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Spacer()
                Text("\(Int(AppSettings.maxOffset)) px")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Text(offsetHint)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var offsetHint: String {
        switch settings.barPosition {
        case .top:
            if settings.barOffset < 0 {
                return "Offset négatif : la barre déborde légèrement au-dessus de l'écran."
            } else if settings.barOffset < AppSettings.menuBarHeight {
                return "Offset \(Int(settings.barOffset)) px : la barre **chevauche la menu bar** (hauteur ~\(Int(AppSettings.menuBarHeight)) px)."
            } else {
                return "Offset \(Int(settings.barOffset)) px : la barre est **sous la menu bar**."
            }
        case .bottom:
            if settings.barOffset < 0 {
                return "Offset négatif : la barre déborde sous l'écran."
            } else if settings.barOffset < 80 {
                return "Offset \(Int(settings.barOffset)) px : la barre peut chevaucher le Dock (selon sa hauteur)."
            } else {
                return "Offset \(Int(settings.barOffset)) px : la barre est au-dessus du Dock."
            }
        }
    }

    private var quickPresetsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Préréglages rapides")
                .font(.headline)

            HStack(spacing: 10) {
                offsetPresetButton("Très haut", offset: 0)
                offsetPresetButton("Sous menu bar", offset: AppSettings.menuBarHeight)
                offsetPresetButton("+50 px", offset: 50)
                offsetPresetButton("+150 px", offset: 150)
                Spacer(minLength: 0)
            }
        }
    }

    private func offsetPresetButton(_ title: String, offset: CGFloat) -> some View {
        let isActive = abs(settings.barOffset - offset) < 0.5
        return Button {
            settings.barOffset = offset
        } label: {
            Text(title)
                .font(.caption.weight(.medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
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

    private var screenPreviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Aperçu")
                .font(.headline)

            GeometryReader { geo in
                let h = max(6.0, min(20.0, geo.size.height * 0.10))
                ZStack(alignment: .top) {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(NSColor.windowBackgroundColor))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(Color.secondary.opacity(0.25), lineWidth: 1)
                        )

                    if settings.barPosition == .top {
                        let verticalOffset = max(0, min(geo.size.height - h - 8, geo.size.height * (settings.barOffset / AppSettings.maxOffset) * 0.7))
                        RoundedRectangle(cornerRadius: 2, style: .continuous)
                            .fill(settings.monitorType == .ram ? settings.ramColor : settings.batteryColor)
                            .frame(width: geo.size.width * 0.62, height: h)
                            .padding(EdgeInsets(top: 4 + verticalOffset, leading: 0, bottom: 0, trailing: 0))
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        let verticalOffset = max(0, min(geo.size.height - h - 8, geo.size.height * (settings.barOffset / AppSettings.maxOffset) * 0.7))
                        RoundedRectangle(cornerRadius: 2, style: .continuous)
                            .fill(settings.monitorType == .ram ? settings.ramColor : settings.batteryColor)
                            .frame(width: geo.size.width * 0.62, height: h)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 4 + verticalOffset, trailing: 0))
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .frame(height: 220)
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
