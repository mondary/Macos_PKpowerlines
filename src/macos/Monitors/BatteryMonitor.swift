import Foundation
import IOKit
import IOKit.ps

struct BatteryUsage {
    let percentage: Double
    let isCharging: Bool
    let isPlugged: Bool
    /// Flux instantané de la batterie en watts (positif = charge, négatif = décharge).
    let powerWatts: Double?
    /// Consommation instantanée du système en watts (télémétrie SMC), si disponible.
    let systemLoadWatts: Double?
}

final class BatteryMonitor {
    func getBatteryUsage() -> BatteryUsage {
        let telemetry = readSmartBatteryTelemetry()
        guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue() else {
            return BatteryUsage(percentage: -1, isCharging: false, isPlugged: false,
                                powerWatts: nil, systemLoadWatts: nil)
        }
        let sources = IOPSCopyPowerSourcesList(snapshot).takeRetainedValue() as Array
        for source in sources {
            if let desc = IOPSGetPowerSourceDescription(snapshot, source)?.takeUnretainedValue() as? [String: Any] {
                let current = desc[kIOPSCurrentCapacityKey] as? Int ?? 0
                let max = desc[kIOPSMaxCapacityKey] as? Int ?? 100
                let percentage = max > 0 ? Double(current) / Double(max) * 100 : -1
                // IOPS met ~1 min à basculer après branchement : l'état réel
                // (IsCharging / ExternalConnected de l'IORegistry) bascule en ~1 s.
                let isCharging = telemetry.isCharging
                    ?? ((desc[kIOPSIsChargingKey] as? Bool) ?? false)
                let isPlugged = telemetry.externalConnected
                    ?? ((desc[kIOPSPowerSourceStateKey] as? String) == kIOPSACPowerValue)
                let powerWatts = Self.signedPower(telemetry.batteryWatts, isCharging: isCharging, isPlugged: isPlugged)
                return BatteryUsage(percentage: percentage, isCharging: isCharging, isPlugged: isPlugged,
                                    powerWatts: powerWatts, systemLoadWatts: telemetry.systemLoadWatts)
            }
        }
        return BatteryUsage(percentage: -1, isCharging: false, isPlugged: false,
                            powerWatts: nil, systemLoadWatts: nil)
    }

    private struct Telemetry {
        var batteryWatts: Double?
        var systemLoadWatts: Double?
        var isCharging: Bool?
        var externalConnected: Bool?
    }

    /// Lit `AppleSmartBattery` dans l'IORegistry : tension × ampérage instantané
    /// pour le flux de la batterie, `PowerTelemetryData.SystemLoad` (mW) pour la
    /// consommation réelle du système, et l'état branché/charge réactif.
    private func readSmartBatteryTelemetry() -> Telemetry {
        let empty = Telemetry(batteryWatts: nil, systemLoadWatts: nil, isCharging: nil, externalConnected: nil)
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("AppleSmartBattery"))
        guard service != IO_OBJECT_NULL else { return empty }
        defer { IOObjectRelease(service) }

        var props: Unmanaged<CFMutableDictionary>?
        guard IORegistryEntryCreateCFProperties(service, &props, kCFAllocatorDefault, 0) == kIOReturnSuccess,
              let dict = props?.takeRetainedValue() as? [String: Any] else {
            return empty
        }

        var batteryWatts: Double?
        let voltage = (dict["Voltage"] as? Int) ?? (dict["AppleRawBatteryVoltage"] as? Int)
        let amperage = (dict["InstantAmperage"] as? Int) ?? (dict["Amperage"] as? Int)
        if let voltage, voltage > 0, let amperage {
            batteryWatts = Double(voltage) * Double(amperage) / 1_000_000
        }

        var systemLoadWatts: Double?
        if let telemetry = dict["PowerTelemetryData"] as? [String: Any],
           let systemLoad = telemetry["SystemLoad"] as? Double {
            systemLoadWatts = systemLoad / 1_000
        }

        return Telemetry(
            batteryWatts: batteryWatts,
            systemLoadWatts: systemLoadWatts,
            isCharging: dict["IsCharging"] as? Bool,
            externalConnected: dict["ExternalConnected"] as? Bool
        )
    }

    /// L'ampérage est signé sur Apple Silicon mais lissé : juste après un
    /// branchement il peut encore être négatif. On aligne le signe sur l'état
    /// réel : positif si charge, négatif si sur batterie, nul branché sans charge.
    private static func signedPower(_ watts: Double?, isCharging: Bool, isPlugged: Bool) -> Double? {
        guard let w = watts else { return nil }
        if isCharging { return abs(w) }
        if !isPlugged { return -abs(w) }
        return 0
    }
}
