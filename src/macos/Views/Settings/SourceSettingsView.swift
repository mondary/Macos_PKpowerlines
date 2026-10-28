import SwiftUI

struct SourceSettingsView: View {
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        Form {
            Section("Source suivie") {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                    ForEach(MonitorType.allCases) { type in
                        sourceCard(type)
                    }
                }
                .padding(.vertical, 2)
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

            sourceSections
        }
        .formStyle(.grouped)
    }

    // MARK: - Couleurs contextuelles à la source choisie

    @ViewBuilder
    private var sourceSections: some View {
        switch settings.monitorType {
        case .ram:
            Section("Couleur RAM") {
                ColorPicker("Couleur", selection: ramColorBinding, supportsOpacity: false)
                EffectPreviewBox(state: .discharging, percentage: 62, color: settings.ramColor)
            }
        case .cpu:
            Section("Couleur CPU") {
                ColorPicker("Couleur", selection: cpuColorBinding, supportsOpacity: false)
                EffectPreviewBox(state: .discharging, percentage: 37, color: settings.cpuColor)
            }
        case .network:
            Section("Réseau") {
                ColorPicker("Couleur", selection: networkColorBinding, supportsOpacity: false)
                HStack(spacing: 12) {
                    Slider(value: $settings.networkMaxMBps, in: 1...1000)
                    Text("\(Int(settings.networkMaxMBps)) MB/s").monospacedDigit()
                        .frame(width: 80, alignment: .trailing).foregroundStyle(.secondary)
                }
                Text("La barre se remplit proportionnellement au débit cumulé (↓ + ↑) par rapport à ce plafond. Le texte affiche toujours les débits réels.")
                    .font(.caption).foregroundStyle(.secondary)
                EffectPreviewBox(state: .discharging, percentage: 42, color: settings.networkColor)
            }
        case .battery:
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
                EffectPreviewBox(state: .full, style: settings.fullAnimation, percentage: 100, color: settings.batteryFullColor)
                Text("Pleine (100 %) — couleur dédiée + animation de plein.")
                    .font(.caption).foregroundStyle(.secondary)
            }

            Section("Couleurs batterie") {
                ColorPicker("Chargée", selection: batteryColorBinding, supportsOpacity: false)
                ColorPicker("Pleine (100 %)", selection: batteryFullColorBinding, supportsOpacity: false)
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
        }
    }

    // MARK: - Cartes de source

    private func sourceCard(_ type: MonitorType) -> some View {
        let active = settings.monitorType == type
        return Button {
            settings.monitorType = type
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: type.icon)
                        .font(.system(size: 16, weight: .medium))
                        .frame(width: 22)
                        .foregroundStyle(active ? Color.accentColor : Color.secondary)
                    Text(type.displayName)
                        .font(.callout.weight(active ? .semibold : .regular))
                    Spacer(minLength: 0)
                    if active {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.accentColor)
                    }
                }
                Text(type.description)
                    .font(.caption2).foregroundStyle(.secondary)
                    .lineLimit(2, reservesSpace: true)
                    .multilineTextAlignment(.leading)
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(active ? Color.accentColor.opacity(0.1) : Color(nsColor: .controlBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(active ? Color.accentColor : Color.secondary.opacity(0.25), lineWidth: active ? 1.5 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Bindings couleurs

    private var ramColorBinding: Binding<Color> {
        Binding(get: { settings.ramColor }, set: { settings.ramColorHex = $0.toHex() })
    }
    private var batteryColorBinding: Binding<Color> {
        Binding(get: { settings.batteryColor }, set: { settings.batteryColorHex = $0.toHex() })
    }
    private var batteryLowColorBinding: Binding<Color> {
        Binding(get: { settings.batteryLowColor }, set: { settings.batteryLowColorHex = $0.toHex() })
    }
    private var batteryFullColorBinding: Binding<Color> {
        Binding(get: { settings.batteryFullColor }, set: { settings.batteryFullColorHex = $0.toHex() })
    }
    private var cpuColorBinding: Binding<Color> {
        Binding(get: { settings.cpuColor }, set: { settings.cpuColorHex = $0.toHex() })
    }
    private var networkColorBinding: Binding<Color> {
        Binding(get: { settings.networkColor }, set: { settings.networkColorHex = $0.toHex() })
    }
}
