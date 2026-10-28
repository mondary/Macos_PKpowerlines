import SwiftUI

struct AnimationsSettingsView: View {
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        Form {
            Section("Au repos") {
                AnimationStatePicker(
                    options: BarAnimation.idleOptions,
                    selection: $settings.idleAnimation,
                    state: .idle,
                    percentage: 45
                )
                Text("Batterie normale, hors charge et hors alerte.")
                    .font(.caption).foregroundStyle(.secondary)
            }

            Section("En charge") {
                AnimationStatePicker(
                    options: BarAnimation.chargingOptions,
                    selection: $settings.chargingAnimation,
                    state: .charging,
                    percentage: 62
                )
                Text("Le chargeur est branché.")
                    .font(.caption).foregroundStyle(.secondary)
            }

            Section("En décharge") {
                AnimationStatePicker(
                    options: BarAnimation.dischargingOptions,
                    selection: $settings.dischargingAnimation,
                    state: .discharging,
                    percentage: 88
                )
                Text("Sur batterie, hors alerte.")
                    .font(.caption).foregroundStyle(.secondary)
            }

            Section("Alerte critique") {
                AnimationStatePicker(
                    options: BarAnimation.criticalOptions,
                    selection: $settings.criticalAnimation,
                    state: .critical,
                    percentage: 8
                )
                Text("Sous le seuil critique (hors charge) — couleur « Faible » et % forcé.")
                    .font(.caption).foregroundStyle(.secondary)
            }

            Section {
                Text("Une seule animation par état : c'est celle qui joue quand la batterie est dans cet état. Les aperçus utilisent la vraie barre et tes réglages ; ils jouent même les animations non sélectionnées.")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
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
