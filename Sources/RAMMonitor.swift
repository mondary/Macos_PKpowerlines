import Foundation

struct RAMUsage {
    let usedPercentage: Double
    let usedGB: Double
    let totalGB: Double
}

class RAMMonitor {
    func getRAMUsage() -> RAMUsage {
        var totalMemory: UInt64 = 0
        var size = MemoryLayout<UInt64>.size
        
        sysctlbyname("hw.memsize", &totalMemory, &size, nil, 0)

        var vmStat = vm_statistics64()
        var count = UInt32(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)

        let result = withUnsafeMutablePointer(to: &vmStat) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }

        guard result == KERN_SUCCESS else {
            return RAMUsage(usedPercentage: 0, usedGB: 0, totalGB: 0)
        }

        let pageSize = vm_kernel_page_size
        let freeMemory = UInt64(vmStat.free_count) * UInt64(pageSize)
        let inactiveMemory = UInt64(vmStat.inactive_count) * UInt64(pageSize)
        let activeMemory = UInt64(vmStat.active_count) * UInt64(pageSize)
        let wiredMemory = UInt64(vmStat.wire_count) * UInt64(pageSize)

        let usedMemory = activeMemory + wiredMemory
        let availableMemory = freeMemory + inactiveMemory
        let totalVM = usedMemory + availableMemory

        let usedPercentage = Double(usedMemory) / Double(totalVM) * 100
        let usedGB = Double(usedMemory) / (1024.0 * 1024.0 * 1024.0)
        let totalGB = Double(totalMemory) / (1024.0 * 1024.0 * 1024.0)

        return RAMUsage(
            usedPercentage: min(usedPercentage, 100),
            usedGB: usedGB,
            totalGB: totalGB
        )
    }
}
