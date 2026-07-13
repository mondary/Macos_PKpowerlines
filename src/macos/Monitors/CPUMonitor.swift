import Foundation

struct CPUUsage {
    let percentage: Double
}

final class CPUMonitor {
    private var previousTotal: UInt64 = 0
    private var previousIdle: UInt64 = 0

    /// Charge CPU globale calculée par delta entre deux appels.
    /// Le premier appel renvoie la moyenne depuis le boot (dégrade gracieusement).
    func getCPUUsage() -> CPUUsage {
        var cpuLoad = host_cpu_load_info()
        var count = UInt32(MemoryLayout<host_cpu_load_info>.size / MemoryLayout<integer_t>.size)
        let result = withUnsafeMutablePointer(to: &cpuLoad) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &count)
            }
        }
        guard result == KERN_SUCCESS else { return CPUUsage(percentage: 0) }

        let user   = UInt64(cpuLoad.cpu_ticks.0)
        let system = UInt64(cpuLoad.cpu_ticks.1)
        let idle   = UInt64(cpuLoad.cpu_ticks.2)
        let nice   = UInt64(cpuLoad.cpu_ticks.3)

        let total = user + system + idle + nice
        let totalDelta = total > previousTotal ? total - previousTotal : 0
        let idleDelta = idle > previousIdle ? idle - previousIdle : 0
        previousTotal = total
        previousIdle = idle

        guard totalDelta > 0 else { return CPUUsage(percentage: 0) }
        let used = totalDelta > idleDelta ? totalDelta - idleDelta : 0
        let usage = Double(used) / Double(totalDelta) * 100
        return CPUUsage(percentage: min(max(usage, 0), 100))
    }
}
