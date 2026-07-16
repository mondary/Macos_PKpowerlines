import SwiftUI

struct PowerlineSettingsView: View {
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                sourceSection
                displaySection
                intervalSection
                heightSection
                opacitySection
                fontSection
                ramColorSection
                batteryColorSection
                batteryLowSection
                cpuColorSection
                networkSection
                positionSection
                offsetSection
                quickPresetsSection
                shortcutHintSection
            }
            .padding(24)
        }
    }

    // MARK: - Source

    private var sourceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Source suivie", icon: "dot.radiowaves.left.and.right")
            Picker("Source", selection: $settings.monitorType) {
                ForEach(MonitorType.allCases) { type in
                    Label(type.displayName, systemImage: type.icon).tag(type)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .frame(maxWidth: 360, alignment: .leading)

            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "info.circle").foregroundStyle(.secondary)
                Text(settings.monitorType.description)
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
            }
        }
    }

    // MARK: - Display (%)

    private var displaySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Affichage", icon: "text.bubble")
            Toggle("Afficher le % (ou le débit)", isOn: $settings.showPercentage)
                .toggleStyle(.switch)
            Text("Masque le texte sur la barre. La barre powerline reste affichée dans tous les cas. Sous 8 px d'épaisseur, le texte est masqué automatiquement.")
                .font(.caption).foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Frequency

    private var intervalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Fréquence de mise à jour", icon: "clock")
            Stepper(value: $settings.updateInterval, in: AppSettings.minInterval...AppSettings.maxInterval, step: 1) {
                HStack(spacing: 6) {
                    Text("Toutes les")
                    Text("\(Int(settings.updateInterval)) s").monospacedDigit().foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: 320, alignment: .leading)
            Text("Plus l'intervalle est court, plus la barre est réactive, mais aussi plus elle consomme de CPU.")
                .font(.caption).foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Height

    private var heightSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Hauteur de la barre", icon: "arrow.up.and.down")
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 12) {
                    Slider(value: $settings.barHeight, in: AppSettings.minHeight...AppSettings.maxHeight)
                    Text("\(Int(settings.barHeight)) px").monospacedDigit()
                        .frame(width: 56, alignment: .trailing).foregroundStyle(.secondary)
                }
                HStack(spacing: 6) {
                    Text("\(Int(AppSettings.minHeight)) px").font(.caption2).foregroundStyle(.tertiary)
                    Spacer()
                    Text("\(Int(AppSettings.maxHeight)) px").font(.caption2).foregroundStyle(.tertiary)
                }
            }
            HStack(spacing: 10) {
                heightPreset("Extra fin", 4)
                heightPreset("Fin", 8)
                heightPreset("Normal", 12)
                heightPreset("Épais", 20)
                Spacer(minLength: 0)
            }
        }
    }

    // MARK: - Opacity

    private var opacitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Opacité", icon: "circle.lefthalf.filled")
            HStack(spacing: 12) {
                Slider(value: $settings.barOpacity, in: AppSettings.minOpacity...AppSettings.maxOpacity)
                Text("\(Int(settings.barOpacity * 100)) %").monospacedDigit()
                    .frame(width: 56, alignment: .trailing).foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Font

    private var fontSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Police du %", icon: "textformat")
            Picker("Police", selection: $settings.barFont) {
                ForEach(BarFont.allCases) { f in Text(f.displayName).tag(f) }
            }
            .frame(maxWidth: 320)
            Text("La taille s'adapte automatiquement à la hauteur de la barre (de 6 à 22 pt). Le % reste centré verticalement. Masqué automatiquement sous 8 px.")
                .font(.caption).foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            fontPreview
        }
    }

    private var fontPreview: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Aperçu").font(.caption.weight(.medium)).foregroundStyle(.secondary)
            HStack(spacing: 8) {
                ForEach([8, 12, 20, 40], id: \.self) { h in
                    VStack(spacing: 4) {
                        ZStack {
                            Color.darkGray.opacity(0.6)
                            Text("42%")
                                .font(customFont(settings.barFont, height: CGFloat(h)))
                                .foregroundStyle(.white)
                        }
                        .frame(width: 56, height: CGFloat(h))
                        .cornerRadius(2)
                        Text("\(h) px").font(.caption2).foregroundStyle(.tertiary)
                    }
                }
                Spacer()
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(NSColor.controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Colors

    private var ramColorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Couleur RAM", icon: "paintpalette")
            HStack(spacing: 12) {
                ColorPicker("RAM", selection: ramColorBinding, supportsOpacity: false).labelsHidden()
                Text("Couleur affichée quand la source est RAM.")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
            }
        }
    }

    private var batteryColorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Couleur Batterie", icon: "battery.100")
            HStack(spacing: 12) {
                ColorPicker("Batterie", selection: batteryColorBinding, supportsOpacity: false).labelsHidden()
                Text("Couleur quand la batterie est chargée.")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
            }
        }
    }

    private var batteryLowSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Batterie faible", icon: "battery.25")
            HStack(spacing: 12) {
                ColorPicker("Faible", selection: batteryLowColorBinding, supportsOpacity: false).labelsHidden()
                Stepper(value: $settings.batteryLowThreshold, in: 5...50, step: 5) {
                    HStack(spacing: 6) {
                        Text("Seuil")
                        Text("\(settings.batteryLowThreshold) %").monospacedDigit().foregroundStyle(.secondary)
                    }
                }
                Spacer()
            }
            Text("En dessous de ce seuil, la batterie prend la couleur « Faible ». La couleur bleue est utilisée pendant la charge.")
                .font(.caption).foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - CPU color

    private var cpuColorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Couleur CPU", icon: "cpu")
            HStack(spacing: 12) {
                ColorPicker("CPU", selection: cpuColorBinding, supportsOpacity: false).labelsHidden()
                Text("Couleur affichée quand la source est CPU.")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
            }
        }
    }

    // MARK: - Network

    private var networkSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Réseau", icon: "network")
            HStack(spacing: 12) {
                ColorPicker("Réseau", selection: networkColorBinding, supportsOpacity: false).labelsHidden()
                Text("Couleur affichée quand la source est Réseau.")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
            }
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 12) {
                    Slider(value: $settings.networkMaxMBps, in: 1...1000)
                    Text("\(Int(settings.networkMaxMBps)) MB/s").monospacedDigit()
                        .frame(width: 80, alignment: .trailing).foregroundStyle(.secondary)
                }
                HStack(spacing: 6) {
                    Text("1 MB/s").font(.caption2).foregroundStyle(.tertiary)
                    Spacer()
                    Text("Plafond = 100 %").font(.caption2).foregroundStyle(.tertiary)
                    Spacer()
                    Text("1000 MB/s").font(.caption2).foregroundStyle(.tertiary)
                }
            }
            Text("La barre se remplit proportionnellement au débit cumulé (↓ + ↑) par rapport à ce plafond. Le texte affiche toujours les débits réels.")
                .font(.caption).foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Position

    private var positionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Côté de l'écran", icon: "rectangle.portrait")
            Picker("Position", selection: $settings.barPosition) {
                ForEach(BarPosition.allCases) { p in
                    Label(p.displayName, systemImage: p.icon).tag(p)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .frame(maxWidth: 360)
            Text("L'ancre se fait sur le bord brut de l'écran (menu bar et Dock inclus). L'offset ci-dessous permet de descendre ou monter la barre au pixel près.")
                .font(.caption).foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var offsetSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Offset vertical", icon: "arrow.up.arrow.down")
            HStack(spacing: 12) {
                Slider(value: $settings.barOffset, in: AppSettings.minOffset...AppSettings.maxOffset)
                Stepper(value: $settings.barOffset, in: AppSettings.minOffset...AppSettings.maxOffset, step: 1) {
                    Text("\(Int(settings.barOffset)) px").monospacedDigit()
                        .frame(width: 72, alignment: .trailing).foregroundStyle(.secondary)
                }
            }
            HStack(spacing: 6) {
                Text("\(Int(AppSettings.minOffset)) px").font(.caption2).foregroundStyle(.tertiary)
                Spacer()
                Text("\(Int(AppSettings.maxOffset)) px").font(.caption2).foregroundStyle(.tertiary)
            }
            Text(offsetHint)
                .font(.caption).foregroundStyle(.secondary)
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
        case .left:
            if settings.barOffset < 0 {
                return "Offset négatif : la barre déborde à gauche de l'écran."
            } else {
                return "Offset \(Int(settings.barOffset)) px : décale la barre vers la droite depuis le bord gauche."
            }
        case .right:
            if settings.barOffset < 0 {
                return "Offset négatif : la barre déborde à droite de l'écran."
            } else {
                return "Offset \(Int(settings.barOffset)) px : décale la barre vers la gauche depuis le bord droit."
            }
        }
    }

    private var quickPresetsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Préréglages rapides", icon: "wand.and.stars")
            HStack(spacing: 10) {
                offsetPreset("Très haut", 0)
                offsetPreset("Sous menu bar", AppSettings.menuBarHeight)
                offsetPreset("+50 px", 50)
                offsetPreset("+150 px", 150)
                Spacer(minLength: 0)
            }
        }
    }

    private var shortcutHintSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Raccourcis", icon: "keyboard")
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

    // MARK: - Helpers

    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon).foregroundStyle(.tint)
            Text(title).font(.headline)
        }
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

    private var ramColorBinding: Binding<Color> {
        Binding(get: { settings.ramColor }, set: { settings.ramColorHex = $0.toHex() })
    }
    private var batteryColorBinding: Binding<Color> {
        Binding(get: { settings.batteryColor }, set: { settings.batteryColorHex = $0.toHex() })
    }
    private var batteryLowColorBinding: Binding<Color> {
        Binding(get: { settings.batteryLowColor }, set: { settings.batteryLowColorHex = $0.toHex() })
    }
    private var cpuColorBinding: Binding<Color> {
        Binding(get: { settings.cpuColor }, set: { settings.cpuColorHex = $0.toHex() })
    }
    private var networkColorBinding: Binding<Color> {
        Binding(get: { settings.networkColor }, set: { settings.networkColorHex = $0.toHex() })
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
        }
    }
}
