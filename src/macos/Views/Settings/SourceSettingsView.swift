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
                Text("La batterie évolue lentement : 10 s suffisent largement. Réserve 1–2 s aux sources vives (RAM, CPU, réseau).")
                    .font(.caption).foregroundStyle(.secondary)
            }

            Section("Affichage du texte") {
                Toggle("Afficher le % (ou le débit)", isOn: $settings.showPercentage)
                    .toggleStyle(.switch)
                Text("Masque le texte sur la barre. La barre powerline reste affichée dans tous les cas ; le % s'écrit sur la ligne, levé au-dessus du bord de l'écran.")
                    .font(.caption).foregroundStyle(.secondary)

                Toggle("Forcer le % en batterie faible", isOn: $settings.forcePercentageWhenLow)
                    .toggleStyle(.switch)
                    .disabled(settings.monitorType != .battery)
                Text("Quand la batterie passe sous le seuil « Faible » (zone rouge), le % s'affiche en permanence, même si l'option ci-dessus est désactivée. La barre garde son épaisseur.")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
    }
}
