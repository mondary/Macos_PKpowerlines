import SwiftUI

struct ColorsSettingsView: View {
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        Form {
            Section("États de la batterie") {
                EffectPreviewBox(state: .idle, percentage: 62, color: settings.batteryColor)
                Text("Chargée — couleur « Chargée », avec l'animation de repos choisie.")
                    .font(.caption).foregroundStyle(.secondary)
                EffectPreviewBox(state: .idle, percentage: 15, color: settings.batteryLowColor)
                Text("Faible — couleur « Faible » sous le seuil.")
                    .font(.caption).foregroundStyle(.secondary)
                EffectPreviewBox(state: .critical, style: .pulse, percentage: 8, color: settings.batteryLowColor)
                Text("Critique — pulsation d'alerte sous le seuil critique.")
                    .font(.caption).foregroundStyle(.secondary)
                EffectPreviewBox(state: .charging, style: .spark, percentage: 62, color: settings.chargingColor)
                Text("En charge — couleur de charge + étincelle.")
                    .font(.caption).foregroundStyle(.secondary)
            }

            Section("RAM") {
                ColorPicker("Couleur", selection: ramColorBinding, supportsOpacity: false)
                Text("Couleur affichée quand la source est RAM.")
                    .font(.caption).foregroundStyle(.secondary)
            }

            Section("Batterie") {
                ColorPicker("Chargée", selection: batteryColorBinding, supportsOpacity: false)
                ColorPicker("Faible", selection: batteryLowColorBinding, supportsOpacity: false)
                Stepper(value: $settings.batteryLowThreshold, in: 5...50, step: 5) {
                    HStack(spacing: 6) {
                        Text("Seuil")
                        Text("\(settings.batteryLowThreshold) %").monospacedDigit().foregroundStyle(.secondary)
                    }
                }
                Stepper(value: $settings.batteryCriticalThreshold, in: 3...min(20, settings.batteryLowThreshold), step: 1) {
                    HStack(spacing: 6) {
                        Text("Seuil critique")
                        Text("\(min(settings.batteryCriticalThreshold, settings.batteryLowThreshold)) %").monospacedDigit().foregroundStyle(.secondary)
                    }
                }
                Text("La couleur bleue est utilisée pendant la charge, avec un balayage électrique qui parcourt la barre. En dessous du seuil, la couleur « Faible » prend le relais ; sous le seuil critique (hors charge), la barre pulse comme une alerte.")
                    .font(.caption).foregroundStyle(.secondary)
            }

            Section("CPU") {
                ColorPicker("Couleur", selection: cpuColorBinding, supportsOpacity: false)
                Text("Couleur affichée quand la source est CPU.")
                    .font(.caption).foregroundStyle(.secondary)
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
