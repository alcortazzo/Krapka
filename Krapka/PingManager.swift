import Foundation
import Network
import SwiftUI

class PingManager: ObservableObject {
    @Published var latencies: [LatencyData] = []
    @Published var color: Color = .green

    private let command = """
        output=$(ping -c 2 -i 0.2 1.1.1.1 2>/dev/null)
        if echo "$output" | grep -q "100.0% packet loss"; then
            echo ""
        else
            echo "$output" | awk -F 'time=' 'NR==3 {print $2}' | awk '{print $1}'
        fi
    """
    private let maxResults = 60
    private var timer: Timer?
    private let session: URLSession = .init(configuration: .default)
    private let interval: TimeInterval = 1.0

    func startPinging() {
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.ping()
        }
    }

    func stopPinging() {
        timer?.invalidate()
        timer = nil
    }

    private func ping() {
        print("Pinging...")
        var result: String = shell(command)
        result = result.trimmingCharacters(in: .newlines)

        if result.isEmpty {
            addLatency(LatencyData(rawValue: "0.0"))
            color = .red
        } else {
            let latency = LatencyData(rawValue: result)
            addLatency(latency)

            if latency.latency <= 50 {
                color = .green
            } else {
                color = .yellow
            }
        }
        print("Latency: \(result)")
    }

    private func addLatency(_ latency: LatencyData) {
        if latencies.count >= maxResults {
            latencies.removeFirst()
        }
        latencies.append(latency)
    }
}
