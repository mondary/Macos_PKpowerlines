import Foundation

/// Animation jouée par la powerline, choisie **par état** de la batterie.
enum BarAnimation: String, CaseIterable, Identifiable {
    case none
    case flow
    case waves
    case twinkle
    case breathing
    case spark
    case consumption
    case pulse
    case stream
    case pulses
    case scan

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .none: return "Aucune"
        case .flow: return "Flux animé"
        case .waves: return "Ondes"
        case .twinkle: return "Scintillement"
        case .breathing: return "Respiration"
        case .spark: return "Étincelle"
        case .consumption: return "Consommation"
        case .pulse: return "Pulsation d'alerte"
        case .stream: return "Flux de données"
        case .pulses: return "Impulsions"
        case .scan: return "Défilé"
        }
    }

    var caption: String {
        switch self {
        case .none: return "La barre reste figée, fidèle au niveau."
        case .flow: return "Vague fluide et discrète du remplissage (2 px)."
        case .waves: return "Deux bandes lumineuses traversent le remplissage."
        case .twinkle: return "Petits éclats qui apparaissent à rythmes décalés."
        case .breathing: return "L'opacité respire doucement (± 7 %)."
        case .spark: return "Balayage lumineux électrique pendant la charge."
        case .consumption: return "Le bord s'érode et fume, comme consommé."
        case .pulse: return "Battement d'alerte de l'opacité."
        case .stream: return "Petits paquets lumineux qui filent avec le débit."
        case .pulses: return "Ondes cadencées : plus le débit monte, plus ça pulse vite."
        case .scan: return "Une encoche sombre parcourt la ligne — visible même à 2 px."
        }
    }

    /// Options proposées selon l'état de la batterie. Il n'y a pas d'état
    /// « repos » : un portable est toujours soit en charge, soit en décharge.
    static let chargingOptions: [BarAnimation] = [.none, .spark, .flow, .waves]
    static let dischargingOptions: [BarAnimation] = [.none, .consumption, .flow, .waves, .twinkle, .breathing]
    static let criticalOptions: [BarAnimation] = [.none, .pulse, .breathing]
    static let levelOptions: [BarAnimation] = [.none, .flow, .waves, .twinkle, .breathing, .scan]
    static let fullOptions: [BarAnimation] = [.scan, .none, .flow, .waves, .twinkle, .breathing]
    static let networkOptions: [BarAnimation] = [.none, .stream, .pulses, .flow, .waves, .scan]
}
