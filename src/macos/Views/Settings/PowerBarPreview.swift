import SwiftUI

/// Vraie `PowerBarView` embarquée dans les réglages : ce que voit l'aperçu
/// utilise exactement le même code de rendu et d'animation que la barre réelle.
struct PowerBarPreview: NSViewRepresentable {
    @EnvironmentObject var settings: AppSettings

    /// États forcés pour illustrer un effet (charge, décharge, alerte).
    var charging = false
    var discharging = false
    var critical = false
    var percentage: Double = 62
    /// Position simulée (l'aperçu Position s'en sert pour ancrer la barre).
    var position: BarPosition = .top
    /// Couleur imposée (aperçu des états batterie).
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
        view.updateAnimatedFlow(settings.animatedFlow)
        view.updateSparkEnabled(settings.sparkOnCharge)
        view.updateCriticalPulseEnabled(settings.criticalPulse)
        view.updateConsumptionEnabled(settings.consumptionEffect)
        view.updateWavesEnabled(settings.fillWaves)
        view.updateTwinklesEnabled(settings.twinkles)
        view.updateBreathingEnabled(settings.breathing)
        view.updateCharging(charging)
        view.updateDischarging(discharging)
        view.updateCriticalLow(critical)
        let prefix = charging ? "⚡ " : ""
        view.updateUsage(
            percentage: percentage,
            color: NSColor(colorOverride ?? previewColor),
            label: "\(prefix)\(Int(percentage))%"
        )
    }

    private var previewColor: Color {
        switch settings.monitorType {
        case .ram:
            return settings.ramColor
        case .cpu:
            return settings.cpuColor
        case .network:
            return settings.networkColor
        case .battery:
            if charging { return settings.chargingColor }
            if critical { return settings.batteryLowColor }
            return settings.batteryColor
        }
    }
}

/// Boîte sombre avec la barre collée en haut : reproduit le bord de l'écran
/// (le texte levé est coupé au bord supérieur, comme en vrai).
struct EffectPreviewBox: View {
    @EnvironmentObject var settings: AppSettings
    var charging = false
    var discharging = false
    var critical = false
    var percentage: Double = 62
    var color: Color? = nil

    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(
                colors: [Color(white: 0.16), Color(white: 0.09)],
                startPoint: .top, endPoint: .bottom
            )
            PowerBarPreview(
                charging: charging,
                discharging: discharging,
                critical: critical,
                percentage: percentage,
                colorOverride: color
            )
            .frame(height: max(16, settings.barHeight))
        }
        .frame(height: 42)
        .frame(maxWidth: .infinity)
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

/// Faux écran pour la page Position : montre le bord choisi, l'offset réel
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
