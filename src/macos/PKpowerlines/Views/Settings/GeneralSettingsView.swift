import SwiftUI

struct GeneralSettingsView: View {
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                sourceSection
                intervalSection
                aboutSection
            }
            .padding(24)
        }
    }

    private var sourceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Source suivie")
                .font(.headline)

            Picker("Source", selection: $settings.monitorType) {
                ForEach(MonitorType.allCases) { type in
                    Label(type.displayName, systemImage: type.icon).tag(type)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .frame(maxWidth: .infinity)

            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "info.circle").foregroundStyle(.secondary)
                Text(settings.monitorType.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
    }

    private var intervalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Fréquence de mise à jour")
                .font(.headline)

            Stepper(value: $settings.updateInterval, in: AppSettings.minInterval...AppSettings.maxInterval, step: 1) {
                HStack(spacing: 6) {
                    Text("Toutes les")
                    Text("\(Int(settings.updateInterval)) s")
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: 320, alignment: .leading)

            Text("Plus l'intervalle est court, plus la barre est réactive, mais aussi plus elle consomme de CPU.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("À propos").font(.headline)
            Text("PKpowerlines affiche une barre en temps réel en haut (ou bas) de chaque écran. Modifie la source, la couleur et la position dans les autres onglets.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
