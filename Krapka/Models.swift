import Charts
import SwiftUI

struct LatencyData: Identifiable {
    let id = UUID()
    let timestamp: Date = .init()

    let rawValue: String
    let latency: Double
    let formattedValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
        latency = Double(rawValue.replacingOccurrences(of: ",", with: ".")) ?? 0.0

        if latency >= 1000 {
            formattedValue = String(format: "%.1f s", latency / 1000)
        } else {
            formattedValue = String(format: "%.2f ms", latency)
        }
    }
}
