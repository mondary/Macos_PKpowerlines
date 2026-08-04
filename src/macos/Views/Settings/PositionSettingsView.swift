import SwiftUI

struct PositionSettingsView: View {
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        Form {
            Section("Côté de l'écran") {
                Picker("Position", selection: $settings.barPosition) {
                    ForEach(BarPosition.allCases) { p in
                        Label(p.displayName, systemImage: p.icon).tag(p)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                Text("L'ancre se fait sur le bord brut de l'écran (menu bar et Dock inclus).")
                    .font(.caption).foregroundStyle(.secondary)
            }

            Section("Offset") {
                HStack(spacing: 12) {
                    Slider(value: $settings.barOffset, in: AppSettings.minOffset...AppSettings.maxOffset)
                    Stepper(value: $settings.barOffset, in: AppSettings.minOffset...AppSettings.maxOffset, step: 1) {
                        Text("\(Int(settings.barOffset)) px").monospacedDigit()
                            .frame(width: 72, alignment: .trailing).foregroundStyle(.secondary)
                    }
                }
                Text(offsetHint)
                    .font(.caption).foregroundStyle(.secondary)
            }

            Section("Préréglages rapides") {
                HStack(spacing: 10) {
                    offsetPreset("Très haut", 0)
                    offsetPreset("Sous menu bar", AppSettings.menuBarHeight)
                    offsetPreset("+50 px", 50)
                    offsetPreset("+150 px", 150)
                    Spacer(minLength: 0)
                }
            }

            Section("Raccourcis") {
                HStack(spacing: 16) {
                    Label("Extra fin  ⌘4", systemImage: "4.circle")
                    Label("Fin  ⌘1", systemImage: "1.circle")
                    Label("Normal  ⌘2", systemImage: "2.circle")
                    Label("Épais  ⌘3", systemImage: "3.circle")
                    Label("Réglages  ⌘,", systemImage: "gearshape")
                    Spacer()
                }
                .font(.caption).foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
    }

    private var offsetHint: String {
        switch settings.barPosition {
        case .top:
            if settings.barOffset < 0 {
                return "Offset négatif : la barre déborde au-dessus de l'écran."
            } else if settings.barOffset < AppSettings.menuBarHeight {
                return "Offset \(Int(settings.barOffset)) px : la barre chevauche la menu bar (~\(Int(AppSettings.menuBarHeight)) px)."
            } else {
                return "Offset \(Int(settings.barOffset)) px : la barre est sous la menu bar."
            }
        case .bottom:
            if settings.barOffset < 0 {
                return "Offset négatif : la barre déborde sous l'écran."
            } else if settings.barOffset < 80 {
                return "Offset \(Int(settings.barOffset)) px : la barre peut chevaucher le Dock."
            } else {
                return "Offset \(Int(settings.barOffset)) px : la barre est au-dessus du Dock."
            }
        case .left:
            return settings.barOffset < 0
                ? "Offset négatif : la barre déborde à gauche."
                : "Offset \(Int(settings.barOffset)) px : décale la barre vers la droite."
        case .right:
            return settings.barOffset < 0
                ? "Offset négatif : la barre déborde à droite."
                : "Offset \(Int(settings.barOffset)) px : décale la barre vers la gauche."
        }
    }

    private func offsetPreset(_ title: String, _ offset: CGFloat) -> some View {
        let active = abs(settings.barOffset - offset) < 0.5
        return Button {
            settings.barOffset = offset
        } label: {
            Text(title)
                .font(.caption.weight(.medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(active ? Color.accentColor.opacity(0.18) : Color(NSColor.controlBackgroundColor))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(active ? Color.accentColor : Color.secondary.opacity(0.25), lineWidth: active ? 1.5 : 1)
                )
        }
        .buttonStyle(.plain)
    }
}
