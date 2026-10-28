import SwiftUI

struct AppearanceSettingsView: View {
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        Form {
            Section("Aperçu") {
                PositionPreview()
                Text("La vraie barre avec tes réglages : bord, offset, hauteur, opacité, police, texte et animation de repos.")
                    .font(.caption).foregroundStyle(.secondary)
            }

            Section("Position") {
                Picker("Position", selection: $settings.barPosition) {
                    ForEach(BarPosition.allCases) { p in
                        Label(p.displayName, systemImage: p.icon).tag(p)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                Text("L'ancre se fait sur le bord brut de l'écran (menu bar et Dock inclus).")
                    .font(.caption).foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    Slider(value: $settings.barOffset, in: AppSettings.minOffset...AppSettings.maxOffset)
                    Stepper(value: $settings.barOffset, in: AppSettings.minOffset...AppSettings.maxOffset, step: 1) {
                        Text("\(Int(settings.barOffset)) px").monospacedDigit()
                            .frame(width: 72, alignment: .trailing).foregroundStyle(.secondary)
                    }
                }
                Text(offsetHint)
                    .font(.caption).foregroundStyle(.secondary)

                HStack(spacing: 10) {
                    offsetPreset("Très haut", 0)
                    offsetPreset("Sous menu bar", AppSettings.menuBarHeight)
                    offsetPreset("+50 px", 50)
                    offsetPreset("+150 px", 150)
                    Spacer(minLength: 0)
                }
            }

            Section("Hauteur de la ligne") {
                HStack(spacing: 12) {
                    Slider(value: $settings.barHeight, in: AppSettings.minHeight...AppSettings.maxHeight)
                    Text("\(Int(settings.barHeight)) px").monospacedDigit()
                        .frame(width: 56, alignment: .trailing).foregroundStyle(.secondary)
                }
                HStack(spacing: 10) {
                    heightPreset("Extra fin", 4)
                    heightPreset("Fin", 8)
                    heightPreset("Normal", 12)
                    heightPreset("Épais", 20)
                    Spacer(minLength: 0)
                }
                Text("Extra fin reste extra fin : le % déborde de la ligne au lieu de l'épaissir. Raccourcis ⌘4 / ⌘1 / ⌘2 / ⌘3.")
                    .font(.caption).foregroundStyle(.secondary)
            }

            Section("Opacité") {
                HStack(spacing: 12) {
                    Slider(value: $settings.barOpacity, in: AppSettings.minOpacity...AppSettings.maxOpacity)
                    Text("\(Int(settings.barOpacity * 100)) %").monospacedDigit()
                        .frame(width: 56, alignment: .trailing).foregroundStyle(.secondary)
                }
            }

            Section("Texte du %") {
                Toggle("Afficher le % (ou le débit)", isOn: $settings.showPercentage)
                    .toggleStyle(.switch)
                Toggle("Forcer le % en batterie faible", isOn: $settings.forcePercentageWhenLow)
                    .toggleStyle(.switch)
                    .disabled(settings.monitorType != .battery)

                Picker("Police", selection: $settings.barFont) {
                    ForEach(BarFont.allCases) { f in Text(f.displayName).tag(f) }
                }
                HStack(spacing: 8) {
                    Text("Aperçu").font(.caption).foregroundStyle(.secondary)
                    Text("42%")
                        .font(customFont(settings.barFont, height: 16))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(RoundedRectangle(cornerRadius: 5).fill(Color(white: 0.18)))
                }
                Text("Sous 16 px, la ligne reste collée au bord et le % (11 pt) s'écrit dessus, levé au-dessus du bord et débordant dessous.")
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

    private func heightPreset(_ title: String, _ height: CGFloat) -> some View {
        let active = abs(settings.barHeight - height) < 0.01
        return Button { settings.barHeight = height } label: {
            VStack(spacing: 4) {
                Text(title).font(.caption.weight(.medium))
                Text("\(Int(height)) px").font(.caption2).monospacedDigit().foregroundStyle(.secondary)
            }
            .frame(width: 86, height: 48)
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

    private func customFont(_ barFont: BarFont, height: CGFloat) -> SwiftUI.Font {
        let size = max(6, min(height * 0.75, 22))
        switch barFont {
        case .systemBold:    return .system(size: size, weight: .bold)
        case .systemRegular: return .system(size: size)
        case .helveticaNeue: return .custom("Helvetica Neue", size: size)
        case .menlo:         return .custom("Menlo", size: size)
        case .sfMono:        return .custom("SF Mono", size: size)
        case .monaco:        return .custom("Monaco", size: size)
        case .courier:       return .custom("Courier", size: size)
        case .avenirNext:    return .custom("Avenir Next", size: size)
        case .futura:        return .custom("Futura", size: size)
        case .optima:        return .custom("Optima", size: size)
        }
    }
}
