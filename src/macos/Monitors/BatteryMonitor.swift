import Foundation
import IOKit.ps

struct BatteryUsage {
    let percentage: Double
    let isCharging: Bool
    let isPlugged: Bool
}

final class BatteryMonitor {
    func getBatteryUsage() -> BatteryUsage {
        guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue() else {
            return BatteryUsage(percentage: -1, isCharging: false, isPlugged: false)
        }
        let sources = IOPSCopyPowerSourcesList(snapshot).takeRetainedValue() as Array
        for source in sources {
            if let desc = IOPSGetPowerSourceDescription(snapshot, source)?.takeUnretainedValue() as? [String: Any] {
                let current = desc[kIOPSCurrentCapacityKey] as? Int ?? 0
                let max = desc[kIOPSMaxCapacityKey] as? Int ?? 100
                let percentage = max > 0 ? Double(current) / Double(max) * 100 : -1
                let isCharging = (desc[kIOPSIsChargingKey] as? Bool) ?? false
                let isPlugged = (desc[kIOPSPowerSourceStateKey] as? String) == kIOPSACPowerValue
                return BatteryUsage(percentage: percentage, isCharging: isCharging, isPlugged: isPlugged)
            }
        }
        return BatteryUsage(percentage: -1, isCharging: false, isPlugged: false)
    }
}
