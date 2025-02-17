import Foundation
import Network
import SwiftUI

class PingManager: ObservableObject {
    @Published var latencies: [LatencyData] = []
    @Published var color: Color = .green
    @Published var isPinging: Bool = false

    private let command = """
        output=$(ping -c 2 -i 0.2 -t 5 1.1.1.1 2>/dev/null)
        if echo "$output" | grep -q "100.0% packet loss"; then
            echo ""
        else
            echo "$output" | awk -F 'time=' 'NR==3 {print $2}' | awk '{print $1}'
        fi
    """
    private let maxResults = 60
    private var timer: Timer?
    private let session: URLSession = .init(configuration: .default)
    private let interval: TimeInterval = 2.0
    private var isPingingInProgress: Bool = false

    func startPinging() {
        stopPinging()

        isPinging = true
        color = .gray

        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.ping()
        }
        timer?.tolerance = 0.3
    }

    func stopPinging() {
        timer?.invalidate()
        timer = nil

        color = .gray

        isPinging = false
    }

    private func ping() {
        DispatchQueue.global(qos: .background).async {
            guard !self.isPingingInProgress else { return }
            self.isPingingInProgress = true

            let timestamp: Date = .init()
            let result: String = shell(self.command).trimmingCharacters(in: .newlines)

            DispatchQueue.main.async {
                if self.isPinging == false {
                    self.color = .gray
                } else if result.isEmpty {
                    self.addLatency(LatencyData(timestamp: timestamp, rawValue: "0.0"))
                    self.color = .red
                } else {
                    let latency = LatencyData(timestamp: timestamp, rawValue: result)
                    self.addLatency(latency)

                    if latency.latency <= 50 {
                        self.color = .green
                    } else {
                        self.color = .yellow
                    }
                }
                self.isPingingInProgress = false
            }
        }
    }

    private func addLatency(_ latency: LatencyData) {
        if latencies.count >= maxResults {
            latencies.removeFirst()
        }
        latencies.append(latency)
    }
}
