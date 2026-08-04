import SwiftUI

struct AppearanceSettingsView: View {
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        Form {
            Section("Hauteur de la barre") {
                HStack(spacing: 12) {
                    Slider(value: $settings.barHeight, in: AppSettings.minHeight...AppSettings.maxHeight)
                    Text("\(Int(settings.barHeight)) px").monospacedDigit()
                        .frame(width: 56, alignment: .trailing).foregroundStyle(.secondary)
                }
                HStack(spacing: 10) {
                    heightPreset("Extra fin", 4)
                    heightPreset("Fin", 8)
                    heightPreset("Normal", 12)
                    heightPreset("Épais", 20)
                    Spacer(minLength: 0)
                }
            }

            Section("Opacité") {
                HStack(spacing: 12) {
                    Slider(value: $settings.barOpacity, in: AppSettings.minOpacity...AppSettings.maxOpacity)
                    Text("\(Int(settings.barOpacity * 100)) %").monospacedDigit()
                        .frame(width: 56, alignment: .trailing).foregroundStyle(.secondary)
                }
            }

            Section {
                Picker("Police", selection: $settings.barFont) {
                    ForEach(BarFont.allCases) { f in Text(f.displayName).tag(f) }
                }
                Text("La taille s'adapte automatiquement à la hauteur de la barre (de 6 à 22 pt). Masqué automatiquement sous 8 px.")
                    .font(.caption).foregroundStyle(.secondary)
                fontPreview
            } header: {
                Text("Police du %")
            }
        }
        .formStyle(.grouped)
    }

    private var fontPreview: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Aperçu").font(.caption.weight(.medium)).foregroundStyle(.secondary)
            HStack(spacing: 8) {
                ForEach([8, 12, 20, 40], id: \.self) { h in
                    VStack(spacing: 4) {
                        ZStack {
                            Color.darkGray.opacity(0.6)
                            Text("42%")
                                .font(customFont(settings.barFont, height: CGFloat(h)))
                                .foregroundStyle(.white)
                        }
                        .frame(width: 56, height: CGFloat(h))
                        .cornerRadius(2)
                        Text("\(h) px").font(.caption2).foregroundStyle(.tertiary)
                    }
                }
                Spacer()
            }
        }
        .padding(.vertical, 8)
    }

    private func heightPreset(_ title: String, _ height: CGFloat) -> some View {
        let active = abs(settings.barHeight - height) < 0.01
        return Button { settings.barHeight = height } label: {
            VStack(spacing: 4) {
                Text(title).font(.caption.weight(.medium))
                Text("\(Int(height)) px").font(.caption2).monospacedDigit().foregroundStyle(.secondary)
            }
            .frame(width: 86, height: 48)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(active ? Color.accentColor.opacity(0.18) : Color(NSColor.controlBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(active ? Color.accentColor : Color.secondary.opacity(0.25), lineWidth: active ? 1.5 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func customFont(_ barFont: BarFont, height: CGFloat) -> SwiftUI.Font {
        let size = max(6, min(height * 0.75, 22))
        switch barFont {
        case .systemBold:    return .system(size: size, weight: .bold)
        case .systemRegular: return .system(size: size)
        case .helveticaNeue: return .custom("Helvetica Neue", size: size)
        case .menlo:         return .custom("Menlo", size: size)
        case .sfMono:        return .custom("SF Mono", size: size)
        case .monaco:        return .custom("Monaco", size: size)
        case .courier:       return .custom("Courier", size: size)
        }
    }
}
