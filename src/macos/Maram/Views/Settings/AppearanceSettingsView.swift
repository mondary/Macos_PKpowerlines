import SwiftUI

struct AppearanceSettingsView: View {
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                heightSection
                opacitySection
                ramColorSection
                batteryColorSection
                batteryLowSection
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
