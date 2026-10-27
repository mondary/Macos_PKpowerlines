import SwiftUI

struct AnimationsSettingsView: View {
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        Form {
            Section("Effets de la barre") {
                Toggle("Flux animé", isOn: $settings.animatedFlow)
                Text("Vague fluide et discrète du remplissage (2 px), accélérée pendant la charge.")
                    .font(.caption).foregroundStyle(.secondary)
                EffectPreviewBox(percentage: 62)

                Toggle("Étincelle de charge", isOn: $settings.sparkOnCharge)
                Text("Un balayage lumineux électrique parcourt la barre pendant la charge.")
                    .font(.caption).foregroundStyle(.secondary)
                EffectPreviewBox(charging: true, percentage: 62)

                Toggle("Pulsation critique", isOn: $settings.criticalPulse)
                Text("Sous le seuil critique (hors charge), la barre pulse comme un battement d'alerte.")
                    .font(.caption).foregroundStyle(.secondary)
                EffectPreviewBox(critical: true, percentage: 8)

                Toggle("Consommation (érosion + fumée)", isOn: $settings.consumptionEffect)
                Text("En décharge, le bord de la barre s'érode et un fin panache de fumée s'en échappe.")
                    .font(.caption).foregroundStyle(.secondary)
                EffectPreviewBox(discharging: true, percentage: 91)
            }

            Section {
                Text("Ces effets ne changent jamais le niveau affiché : la barre reste fidèle au pourcentage réel, même pendant l'érosion. Les aperçus utilisent la vraie barre avec tes réglages actuels.")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
    }
}
