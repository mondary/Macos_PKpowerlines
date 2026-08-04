import SwiftUI

struct ColorsSettingsView: View {
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        Form {
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
                Text("La couleur bleue est utilisée pendant la charge. En dessous du seuil, la couleur « Faible » prend le relais.")
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
