import Charts
import SwiftUI

struct PingGraphView: View {
    @ObservedObject var pingManager: PingManager

    var body: some View {
        VStack {
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
                    .annotation(position: .automatic) {
                        Text(entry.formattedValue)
                            .font(.caption2)
                            .padding(4)
                            .foregroundColor(.blue)
                    }
                }
            }
            .frame(height: 200, alignment: .center)
            .padding()
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
        }
    }
}
