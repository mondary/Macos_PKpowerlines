import Foundation

struct NetworkUsage {
    let downloadKBps: Double
    let uploadKBps: Double
    let percentage: Double
}

final class NetworkMonitor {
    private var previousBytesIn: UInt64 = 0
    private var previousBytesOut: UInt64 = 0
    private var previousTime: Date?
    private var primed = false

    /// Débit cumulé (toutes interfaces AF_LINK). Le premier appel « amorce » les
    /// compteurs et renvoie 0 pour éviter un pic lié au cumul depuis le boot.
    func getNetworkUsage(maxMBps: Double) -> NetworkUsage {
        var bytesIn: UInt64 = 0
        var bytesOut: UInt64 = 0

        var ifaddrPtr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddrPtr) == 0, let firstAddr = ifaddrPtr else {
            return NetworkUsage(downloadKBps: 0, uploadKBps: 0, percentage: 0)
        }
        defer { freeifaddrs(ifaddrPtr) }

        var pointer: UnsafeMutablePointer<ifaddrs>? = firstAddr
        while let cur = pointer {
            let iface = cur.pointee
            if let addr = iface.ifa_addr, addr.pointee.sa_family == AF_LINK {
                let data = unsafeBitCast(iface.ifa_data, to: UnsafeMutablePointer<if_data>.self).pointee
                bytesIn  += UInt64(data.ifi_ibytes)
                bytesOut += UInt64(data.ifi_obytes)
            }
            pointer = iface.ifa_next
        }

        if !primed {
            previousBytesIn = bytesIn
            previousBytesOut = bytesOut
            previousTime = Date()
            primed = true
            return NetworkUsage(downloadKBps: 0, uploadKBps: 0, percentage: 0)
        }

        let now = Date()
        let elapsed = previousTime.map { now.timeIntervalSince($0) } ?? 0
        previousTime = now

        let deltaIn  = bytesIn  > previousBytesIn  ? bytesIn  - previousBytesIn  : 0
        let deltaOut = bytesOut > previousBytesOut ? bytesOut - previousBytesOut : 0
        previousBytesIn = bytesIn
        previousBytesOut = bytesOut

        guard elapsed > 0 else {
            return NetworkUsage(downloadKBps: 0, uploadKBps: 0, percentage: 0)
        }

        let downKBps = Double(deltaIn) / 1024.0 / elapsed
        let upKBps   = Double(deltaOut) / 1024.0 / elapsed

        let refKBps = max(maxMBps * 1024.0, 1.0)
        let totalKBps = downKBps + upKBps
        let percentage = min(totalKBps / refKBps * 100, 100)

        return NetworkUsage(downloadKBps: downKBps, uploadKBps: upKBps, percentage: percentage)
    }
}
