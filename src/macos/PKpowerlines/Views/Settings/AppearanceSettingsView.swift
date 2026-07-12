import SwiftUI

extension Color {
    static var darkGray: Color { Color(NSColor.darkGray) }
}

struct AppearanceSettingsView: View {
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                fontSection
                heightSection
                opacitySection
                ramColorSection
                batteryColorSection
                batteryLowSection
            }
            .padding(24)
        }
    }

    private var fontSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Police du %")
                .font(.headline)

            Picker("Police", selection: $settings.barFont) {
                ForEach(BarFont.allCases) { f in
                    Text(f.displayName).tag(f)
                }
            }
            .frame(maxWidth: 320)

            Text("La taille s'adapte automatiquement à la hauteur de la barre (de 6 à 22 pt). Le % reste centré verticalement quelle que soit la hauteur. Masqué automatiquement sous 8 px.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            fontPreview
        }
    }

    private var fontPreview: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Aperçu")
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
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
                    Text("\(Int(AppSettings.minHeight)) px").font(.caption2).foregroundStyle(.tertiary)
                    Spacer()
                    Text("\(Int(AppSettings.maxHeight)) px").font(.caption2).foregroundStyle(.tertiary)
                }
            }

            HStack(spacing: 10) {
                presetButton("Fin", height: 8)
                presetButton("Normal", height: 12)
                presetButton("Épais", height: 20)
                Spacer(minLength: 0)
            }
        }
    }

    private var opacitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Opacité")
                .font(.headline)

            HStack(spacing: 12) {
                Slider(value: $settings.barOpacity, in: AppSettings.minOpacity...AppSettings.maxOpacity)
                Text("\(Int(settings.barOpacity * 100)) %")
                    .monospacedDigit()
                    .frame(width: 56, alignment: .trailing)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var ramColorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Couleur RAM")
                .font(.headline)

            HStack(spacing: 12) {
                ColorPicker("RAM", selection: ramColorBinding, supportsOpacity: false)
                    .labelsHidden()
                Text("Couleur affichée quand la source est RAM.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
    }

    private var batteryColorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Couleur Batterie")
                .font(.headline)

            HStack(spacing: 12) {
                ColorPicker("Batterie", selection: batteryColorBinding, supportsOpacity: false)
                    .labelsHidden()
                Text("Couleur quand la batterie est chargée.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
    }

    private var batteryLowSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Batterie faible")
                .font(.headline)

            HStack(spacing: 12) {
                ColorPicker("Faible", selection: batteryLowColorBinding, supportsOpacity: false)
                    .labelsHidden()

                Stepper(value: $settings.batteryLowThreshold, in: 5...50, step: 5) {
                    HStack(spacing: 6) {
                        Text("Seuil")
                        Text("\(settings.batteryLowThreshold) %")
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
            }

            Text("En dessous de ce seuil, la batterie prend la couleur « Faible ». La couleur bleue est utilisée pendant la charge.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
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

    private func presetButton(_ title: String, height: CGFloat) -> some View {
        let isActive = abs(settings.barHeight - height) < 0.01
        return Button { settings.barHeight = height } label: {
            VStack(spacing: 4) {
                Text(title).font(.caption.weight(.medium))
                Text("\(Int(height)) px").font(.caption2).monospacedDigit().foregroundStyle(.secondary)
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
}
