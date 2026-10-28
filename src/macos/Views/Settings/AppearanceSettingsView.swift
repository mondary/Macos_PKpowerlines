import SwiftUI

struct AppearanceSettingsView: View {
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        Form {
            Section("Aperçu") {
                PositionPreview()
                Text("La vraie barre avec tes réglages : bord, offset, hauteur, opacité, police, texte et animations.")
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
                    Section("Classiques") {
                        ForEach(BarFont.builtIns) { f in Text(f.displayName).tag(f) }
                    }
                    if !BarFont.nerdFonts.isEmpty {
                        Section("Nerd Fonts installées (\(BarFont.nerdFonts.count))") {
                            ForEach(BarFont.nerdFonts) { f in Text(f.displayName).tag(f) }
                        }
                    }
                }
                HStack(spacing: 8) {
                    Text("Aperçu").font(.caption).foregroundStyle(.secondary)
                    Text("42%")
                        .font(Font(settings.barFont.nsFont(size: 15)))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(RoundedRectangle(cornerRadius: 5).fill(Color(white: 0.18)))
                }
                Text("Les Nerd Fonts installées sur ton Mac sont détectées automatiquement. Sous 16 px, la ligne reste collée au bord et le % (11 pt) s'écrit dessus, levé au-dessus du bord et débordant dessous.")
                    .font(.caption).foregroundStyle(.secondary)
            }

            Section("Animation — en charge") {
                AnimationGrid(options: BarAnimation.chargingOptions, selection: $settings.chargingAnimation, state: .charging, percentage: 62)
            }

            Section("Animation — en décharge") {
                AnimationGrid(options: BarAnimation.dischargingOptions, selection: $settings.dischargingAnimation, state: .discharging, percentage: 88)
            }

            Section("Animation — alerte critique") {
                AnimationGrid(options: BarAnimation.criticalOptions, selection: $settings.criticalAnimation, state: .critical, percentage: 8)
                Text("Une animation par état : un portable est toujours en charge ou en décharge, il n'y a pas d'état « repos ». Les aperçus jouent aussi les animations non sélectionnées.")
                    .font(.caption).foregroundStyle(.secondary)
            }

            Section("Animation — pleine (100 %)") {
                AnimationGrid(options: BarAnimation.fullOptions, selection: $settings.fullAnimation, state: .full, percentage: 100)
            }

            Section("Animation — niveau (RAM & CPU)") {
                AnimationGrid(options: BarAnimation.levelOptions, selection: $settings.levelAnimation, state: .discharging, percentage: 62)
            }

            Section("Animation — réseau") {
                AnimationGrid(options: BarAnimation.networkOptions, selection: $settings.networkAnimation, state: .discharging, percentage: 42)
                Text("Le flux de données accélère avec le débit ; les impulsions se resserrent quand la vitesse monte.")
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
}

/// Grille compacte de cartes d'animation pour un état : chaque carte joue son
/// aperçu en direct, la sélection est cerclée.
private struct AnimationGrid: View {
    let options: [BarAnimation]
    @Binding var selection: BarAnimation
    let state: PreviewState
    let percentage: Double

    private let columns = [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(options) { option in
                Button {
                    selection = option
                } label: {
                    VStack(spacing: 6) {
                        EffectPreviewBox(state: state, style: option, percentage: percentage)
                        HStack(spacing: 5) {
                            Image(systemName: selection == option ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 11))
                                .foregroundStyle(selection == option ? Color.accentColor : Color.secondary.opacity(0.45))
                            Text(option.displayName)
                                .font(.caption.weight(selection == option ? .semibold : .regular))
                                .lineLimit(1)
                            Spacer(minLength: 0)
                        }
                    }
                    .padding(6)
                    .background(
                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .fill(selection == option ? Color.accentColor.opacity(0.1) : Color(nsColor: .controlBackgroundColor))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .stroke(selection == option ? Color.accentColor : Color.clear, lineWidth: 1.5)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 2)
    }
}
