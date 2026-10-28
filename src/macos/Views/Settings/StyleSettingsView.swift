import SwiftUI

/// Page unique « Couleurs & animations » : les couleurs par source, les états
/// de la batterie et l'animation choisie pour chaque état.
struct StyleSettingsView: View {
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        Form {
            Section("États de la batterie") {
                EffectPreviewBox(state: .discharging, percentage: 62, color: settings.batteryColor)
                Text("Chargée — couleur « Chargée », avec l'animation de décharge.")
                    .font(.caption).foregroundStyle(.secondary)
                EffectPreviewBox(state: .discharging, percentage: 15, color: settings.batteryLowColor)
                Text("Faible — couleur « Faible » sous le seuil.")
                    .font(.caption).foregroundStyle(.secondary)
                EffectPreviewBox(state: .critical, style: settings.criticalAnimation, percentage: 8, color: settings.batteryLowColor)
                Text("Critique — animation d'alerte sous le seuil critique.")
                    .font(.caption).foregroundStyle(.secondary)
                EffectPreviewBox(state: .charging, style: settings.chargingAnimation, percentage: 62, color: settings.chargingColor)
                Text("En charge — couleur de charge + animation de charge.")
                    .font(.caption).foregroundStyle(.secondary)
            }

            Section("RAM") {
                ColorPicker("Couleur", selection: ramColorBinding, supportsOpacity: false)
            }

            Section("CPU") {
                ColorPicker("Couleur", selection: cpuColorBinding, supportsOpacity: false)
            }

            Section("Réseau") {
                ColorPicker("Couleur", selection: networkColorBinding, supportsOpacity: false)
                HStack(spacing: 12) {
                    Slider(value: $settings.networkMaxMBps, in: 1...1000)
                    Text("\(Int(settings.networkMaxMBps)) MB/s").monospacedDigit()
                        .frame(width: 80, alignment: .trailing).foregroundStyle(.secondary)
                }
                Text("La barre se remplit proportionnellement au débit cumulé (↓ + ↑) par rapport à ce plafond. Le texte affiche toujours les débits réels.")
                    .font(.caption).foregroundStyle(.secondary)
            }

            Section("Batterie") {
                ColorPicker("Chargée", selection: batteryColorBinding, supportsOpacity: false)
                ColorPicker("Faible", selection: batteryLowColorBinding, supportsOpacity: false)
                Stepper(value: $settings.batteryLowThreshold, in: 5...50, step: 5) {
                    HStack(spacing: 6) {
                        Text("Seuil faible")
                        Text("\(settings.batteryLowThreshold) %").monospacedDigit().foregroundStyle(.secondary)
                    }
                }
                Stepper(value: $settings.batteryCriticalThreshold, in: 3...min(20, settings.batteryLowThreshold), step: 1) {
                    HStack(spacing: 6) {
                        Text("Seuil critique")
                        Text("\(min(settings.batteryCriticalThreshold, settings.batteryLowThreshold)) %").monospacedDigit().foregroundStyle(.secondary)
                    }
                }
                Text("En dessous du seuil faible, la couleur « Faible » prend le relais ; sous le seuil critique (hors charge), l'animation d'alerte joue.")
                    .font(.caption).foregroundStyle(.secondary)
            }

            Section("Animation — en charge") {
                AnimationStatePicker(
                    options: BarAnimation.chargingOptions,
                    selection: $settings.chargingAnimation,
                    state: .charging,
                    percentage: 62
                )
            }

            Section("Animation — en décharge") {
                AnimationStatePicker(
                    options: BarAnimation.dischargingOptions,
                    selection: $settings.dischargingAnimation,
                    state: .discharging,
                    percentage: 88
                )
            }

            Section("Animation — alerte critique") {
                AnimationStatePicker(
                    options: BarAnimation.criticalOptions,
                    selection: $settings.criticalAnimation,
                    state: .critical,
                    percentage: 8
                )
            }

            Section {
                Text("Une animation par état : c'est celle qui joue quand la batterie est dans cet état (un portable est toujours en charge ou en décharge — il n'y a pas d'état « repos »). Les aperçus jouent aussi les animations non sélectionnées.")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
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
}

/// Liste d'options d'animation pour un état : aperçu animé à gauche, nom et
/// description au centre, coche à droite. L'aperçu joue toujours l'animation.
private struct AnimationStatePicker: View {
    let options: [BarAnimation]
    @Binding var selection: BarAnimation
    let state: PreviewState
    let percentage: Double

    var body: some View {
        VStack(spacing: 8) {
            ForEach(options) { option in
                Button {
                    selection = option
                } label: {
                    HStack(spacing: 12) {
                        EffectPreviewBox(state: state, style: option, percentage: percentage)
                            .frame(width: 210)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(option.displayName)
                                .font(.callout.weight(selection == option ? .semibold : .regular))
                            Text(option.caption)
                                .font(.caption2).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: selection == option ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 15))
                            .foregroundStyle(selection == option ? Color.accentColor : Color.secondary.opacity(0.45))
                    }
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(selection == option ? Color.accentColor.opacity(0.1) : Color(nsColor: .controlBackgroundColor))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(selection == option ? Color.accentColor : Color.clear, lineWidth: 1.5)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 2)
    }
}
