import Charts
import SwiftUI

struct LatencyData: Identifiable {
    let id = UUID()

    let timestamp: Date
    let rawValue: String
    let latency: Double
    let formattedValue: String

    init(timestamp: Date, rawValue: String) {
        self.timestamp = timestamp
        self.rawValue = rawValue
        latency = Double(rawValue.replacingOccurrences(of: ",", with: ".")) ?? 0.0

        if latency >= 1000 {
            formattedValue = String(format: "%.1f s", latency / 1000)
        } else {
            formattedValue = String(format: "%.2f ms", latency)
        }
    }
}
