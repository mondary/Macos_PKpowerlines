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
        }
        .formStyle(.grouped)
    }

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
}
