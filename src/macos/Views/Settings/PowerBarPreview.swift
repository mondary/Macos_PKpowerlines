import SwiftUI

/// État batterie simulé dans les aperçus.
enum PreviewState {
    case idle
    case charging
    case discharging
    case critical
}

/// Vraie `PowerBarView` embarquée dans les réglages : ce que voit l'aperçu
/// utilise exactement le même code de rendu et d'animation que la barre réelle.
struct PowerBarPreview: NSViewRepresentable {
    @EnvironmentObject var settings: AppSettings

    var state: PreviewState = .idle
    /// Animation montrée ; `nil` = celle réglée pour cet état.
    var style: BarAnimation? = nil
    var percentage: Double = 62
    var position: BarPosition = .top
    var colorOverride: Color? = nil

    func makeNSView(context: Context) -> PowerBarView {
        PowerBarView(frame: .zero)
    }

    func updateNSView(_ view: PowerBarView, context: Context) {
        view.updateOrientation(position.isVertical)
        view.updateBarPosition(position)
        view.updateBarThickness(settings.barHeight)
        view.updateShowPercentage(true)
        view.updateOpacity(settings.barOpacity)
        view.updateFont(settings.barFont)
        view.updateCharging(state == .charging)
        view.updateDischarging(state == .discharging)
        view.updateCriticalLow(state == .critical)

        let resolved = style ?? settingsStyle
        view.updateAnimations(
            idle: state == .idle ? resolved : .none,
            charging: state == .charging ? resolved : .none,
            discharging: state == .discharging ? resolved : .none,
            critical: state == .critical ? resolved : .none
        )
        let prefix = state == .charging ? "⚡ " : ""
        view.updateUsage(
            percentage: percentage,
            color: NSColor(colorOverride ?? previewColor),
            label: "\(prefix)\(Int(percentage))%"
        )
    }

    private var settingsStyle: BarAnimation {
        switch state {
        case .idle: return settings.idleAnimation
        case .charging: return settings.chargingAnimation
        case .discharging: return settings.dischargingAnimation
        case .critical: return settings.criticalAnimation
        }
    }

    private var previewColor: Color {
        switch state {
        case .charging: return settings.chargingColor
        case .critical: return settings.batteryLowColor
        case .idle, .discharging:
            switch settings.monitorType {
            case .ram: return settings.ramColor
            case .cpu: return settings.cpuColor
            case .network: return settings.networkColor
            case .battery: return settings.batteryColor
            }
        }
    }
}

/// Boîte sombre avec la barre collée en haut : reproduit le bord de l'écran
/// (le texte levé est coupé au bord supérieur, comme en vrai).
/// L'animation montrée joue TOUJOURS, même si elle n'est pas sélectionnée.
struct EffectPreviewBox: View {
    @EnvironmentObject var settings: AppSettings
    var state: PreviewState = .idle
    var style: BarAnimation? = nil
    var percentage: Double = 62
    var color: Color? = nil

    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(
                colors: [Color(white: 0.16), Color(white: 0.09)],
                startPoint: .top, endPoint: .bottom
            )
            PowerBarPreview(
                state: state,
                style: style,
                percentage: percentage,
                colorOverride: color
            )
            .frame(height: max(16, settings.barHeight))
        }
        .frame(height: 40)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

/// Reproduction miniature d'un bureau : powerline collée en haut d'un faux
/// écran (menu bar + fond), pour prévisualiser hauteur, opacité, police et %.
struct DesktopPreview: View {
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(
                colors: [
                    Color(hue: 0.6, saturation: 0.45, brightness: 0.38),
                    Color(hue: 0.66, saturation: 0.5, brightness: 0.2)
                ],
                startPoint: .top, endPoint: .bottom
            )
            // Fausse menu bar (pilules grises + horloge).
            HStack(spacing: 10) {
                Capsule().fill(.white.opacity(0.32)).frame(width: 14, height: 5)
                Capsule().fill(.white.opacity(0.32)).frame(width: 34, height: 5)
                Capsule().fill(.white.opacity(0.32)).frame(width: 26, height: 5)
                Capsule().fill(.white.opacity(0.32)).frame(width: 44, height: 5)
                Spacer()
                Capsule().fill(.white.opacity(0.32)).frame(width: 30, height: 5)
                Capsule().fill(.white.opacity(0.32)).frame(width: 46, height: 5)
            }
            .padding(.horizontal, 14)
            .padding(.top, 34)
            // La barre réelle, collée au bord haut, coupée par le cadre.
            PowerBarPreview()
                .frame(height: max(16, settings.barHeight))
        }
        .frame(height: 96)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

/// Faux écran pour la page Barre : montre le bord choisi, l'offset réel
/// (plafonné pour rester lisible) et le sens de remplissage.
struct PositionPreview: View {
    @EnvironmentObject var settings: AppSettings

    private var offset: CGFloat {
        min(max(settings.barOffset, 0), 44)
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: alignment) {
                LinearGradient(
                    colors: [
                        Color(hue: 0.6, saturation: 0.45, brightness: 0.38),
                        Color(hue: 0.66, saturation: 0.5, brightness: 0.2)
                    ],
                    startPoint: .top, endPoint: .bottom
                )
                Group {
                    if settings.barPosition.isVertical {
                        PowerBarPreview(percentage: 62, position: settings.barPosition)
                            .frame(width: max(16, settings.barHeight))
                            .frame(maxHeight: .infinity)
                    } else {
                        PowerBarPreview(percentage: 62, position: settings.barPosition)
                            .frame(height: max(16, settings.barHeight))
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(edge, offset)
            }
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .frame(height: 110)
        .frame(maxWidth: .infinity)
    }

    private var alignment: Alignment {
        switch settings.barPosition {
        case .top: .top
        case .bottom: .bottom
        case .left: .leading
        case .right: .trailing
        }
    }

    private var edge: Edge.Set {
        switch settings.barPosition {
        case .top: .top
        case .bottom: .bottom
        case .left: .leading
        case .right: .trailing
        }
    }
}
