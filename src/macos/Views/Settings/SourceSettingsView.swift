import SwiftUI

struct SourceSettingsView: View {
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        Form {
            Section("Source suivie") {
                Picker("Source", selection: $settings.monitorType) {
                    ForEach(MonitorType.allCases) { type in
                        Label(type.displayName, systemImage: type.icon).tag(type)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
                Text(settings.monitorType.description)
                    .font(.caption).foregroundStyle(.secondary)
            }

            Section("Fréquence de mise à jour") {
                Stepper(value: $settings.updateInterval, in: AppSettings.minInterval...AppSettings.maxInterval, step: 1) {
                    HStack(spacing: 6) {
                        Text("Toutes les")
                        Text("\(Int(settings.updateInterval)) s").monospacedDigit().foregroundStyle(.secondary)
                    }
                }
                Text("Plus l'intervalle est court, plus la barre est réactive, mais aussi plus elle consomme de CPU.")
                    .font(.caption).foregroundStyle(.secondary)
            }

            Section("Affichage du texte") {
                Toggle("Afficher le % (ou le débit)", isOn: $settings.showPercentage)
                    .toggleStyle(.switch)
                Text("Masque le texte sur la barre. La barre powerline reste affichée dans tous les cas. Sous 8 px d'épaisseur, le texte est masqué automatiquement.")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
    }
}
