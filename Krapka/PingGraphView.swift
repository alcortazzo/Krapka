import Charts
import SwiftUI

struct PingGraphView: View {
    @ObservedObject var pingManager: PingManager

    var body: some View {
        let latencies = pingManager.latencies.map { $0.latency }
        let averageLatency: Double = latencies.reduce(0, +) / Double(latencies.count)
        let minLatency: Double = latencies.min() ?? 0
        let maxLatency: Double = latencies.max() ?? 0

        VStack(alignment: .leading) {
            Chart {
                ForEach(Array(pingManager.latencies.enumerated()), id: \.offset) { _, entry in
                    LineMark(
                        x: .value("Time", entry.timestamp),
                        y: .value("Latency", entry.latency)
                    )
                    .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    .foregroundStyle(LinearGradient(
                        gradient: Gradient(colors: [.blue, .purple]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                }

                RuleMark(y: .value("Average Latency", averageLatency))
                    .foregroundStyle(Color.red)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                    .annotation(position: .top, alignment: .center) {
                        Text("Avg: \(averageLatency, specifier: "%.2f") ms")
                            .font(.caption)
                            .padding(4)
                    }

                RuleMark(y: .value("Min Latency", minLatency))
                    .foregroundStyle(Color.red)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                    .annotation(position: .top, alignment: .leading) {
                        Text("Min: \(minLatency, specifier: "%.2f") ms")
                            .font(.caption)
                            .padding(4)
                    }

                RuleMark(y: .value("Max Latency", maxLatency))
                    .foregroundStyle(Color.red)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                    .annotation(position: .top, alignment: .trailing) {
                        Text("Max: \(maxLatency, specifier: "%.2f") ms")
                            .font(.caption)
                            .padding(4)
                    }
            }
            .frame(height: 150, alignment: .center)
            .chartXAxis {
                AxisMarks(position: .bottom, values: .automatic) { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic) { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                }
            }

            Divider()

            HStack {
                Text("Last").monospaced()
                Spacer()
                Text("\(latencies.last ?? 0, specifier: "%.2f") ms").monospaced()
            }
            HStack {
                Text("Min").monospaced()
                Spacer()
                Text("\(minLatency, specifier: "%.2f") ms").monospaced()
            }
            HStack {
                Text("Max").monospaced()
                Spacer()
                Text("\(maxLatency, specifier: "%.2f") ms").monospaced()
            }
            HStack {
                Text("Avg").monospaced()
                Spacer()
                Text("\(averageLatency, specifier: "%.2f") ms").monospaced()
            }

            Divider()

            Menu("Options") {
                if pingManager.isPinging {
                    Button("Stop Pinging") {
                        pingManager.stopPinging()
                    }
                } else {
                    Button("Start Pinging") {
                        pingManager.startPinging()
                    }
                }
                Button("Clear Data") {
                    pingManager.latencies.removeAll()
                }
                Button("Quit") {
                    NSApplication.shared.terminate(self)
                }
            }
        }.padding()
    }
}
