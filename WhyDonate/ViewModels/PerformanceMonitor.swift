import Foundation
import SwiftUI
import os.log

// MARK: - Performance Monitor
@MainActor
class PerformanceMonitor: ObservableObject {
    static let shared = PerformanceMonitor()
    
    @Published var metrics: [PerformanceMetric] = []
    @Published var isMonitoring = false
    
    private let logger = Logger(subsystem: "com.whydonate.app", category: "Performance")
    private var startTimes: [String: CFTimeInterval] = [:]
    private let maxMetrics = 100 // Keep only the latest 100 metrics
    
    private init() {}
    
    // MARK: - Public Methods
    func startMonitoring() {
        isMonitoring = true
        logger.info("Performance monitoring started")
    }
    
    func stopMonitoring() {
        isMonitoring = false
        logger.info("Performance monitoring stopped")
    }
    
    func startTimer(for operation: String) {
        guard isMonitoring else { return }
        startTimes[operation] = CACurrentMediaTime()
        logger.debug("Started timing: \(operation)")
    }
    
    func endTimer(for operation: String, category: MetricCategory = .general) {
        guard isMonitoring else { return }
        guard let startTime = startTimes[operation] else {
            logger.warning("No start time found for operation: \(operation)")
            return
        }
        
        let duration = CACurrentMediaTime() - startTime
        let metric = PerformanceMetric(
            operation: operation,
            duration: duration,
            category: category,
            timestamp: Date()
        )
        
        addMetric(metric)
        startTimes.removeValue(forKey: operation)
        
        logger.info("Completed \(operation) in \(String(format: "%.3f", duration * 1000))ms")
    }
    
    func recordMetric(operation: String, duration: TimeInterval, category: MetricCategory = .general) {
        guard isMonitoring else { return }
        
        let metric = PerformanceMetric(
            operation: operation,
            duration: duration,
            category: category,
            timestamp: Date()
        )
        
        addMetric(metric)
        logger.info("Recorded \(operation): \(String(format: "%.3f", duration * 1000))ms")
    }
    
    func getAverageTime(for operation: String) -> TimeInterval? {
        let operationMetrics = metrics.filter { $0.operation == operation }
        guard !operationMetrics.isEmpty else { return nil }
        
        let totalTime = operationMetrics.reduce(0) { $0 + $1.duration }
        return totalTime / Double(operationMetrics.count)
    }
    
    func getSlowOperations(threshold: TimeInterval = 1.0) -> [PerformanceMetric] {
        return metrics.filter { $0.duration > threshold }
    }
    
    func clearMetrics() {
        metrics.removeAll()
        logger.info("Performance metrics cleared")
    }
    
    func exportMetrics() -> String {
        let header = "Operation,Duration(ms),Category,Timestamp\n"
        let csvData = metrics.map { metric in
            "\(metric.operation),\(String(format: "%.3f", metric.duration * 1000)),\(metric.category.rawValue),\(metric.timestamp)"
        }.joined(separator: "\n")
        
        return header + csvData
    }
    
    // MARK: - Private Methods
    private func addMetric(_ metric: PerformanceMetric) {
        metrics.append(metric)
        
        // Keep only the latest metrics
        if metrics.count > maxMetrics {
            metrics.removeFirst(metrics.count - maxMetrics)
        }
        
        // Log warning for slow operations
        if metric.duration > 2.0 {
            logger.warning("Slow operation detected: \(metric.operation) took \(String(format: "%.3f", metric.duration * 1000))ms")
        }
    }
}

// MARK: - Performance Metric Model
struct PerformanceMetric: Identifiable {
    let id = UUID()
    let operation: String
    let duration: TimeInterval // in seconds
    let category: MetricCategory
    let timestamp: Date
    
    var durationInMilliseconds: Double {
        duration * 1000
    }
}

// MARK: - Metric Categories
enum MetricCategory: String, CaseIterable {
    case general = "General"
    case networking = "Networking"
    case database = "Database"
    case ui = "UI"
    case imageLoading = "Image Loading"
    case caching = "Caching"
    case startup = "Startup"
}

// MARK: - Performance Monitoring View Modifier
struct PerformanceMonitoringModifier: ViewModifier {
    let operation: String
    let category: MetricCategory
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                PerformanceMonitor.shared.startTimer(for: "\(operation)_appear")
            }
            .onDisappear {
                PerformanceMonitor.shared.endTimer(for: "\(operation)_appear", category: category)
            }
    }
}

extension View {
    func monitorPerformance(operation: String, category: MetricCategory = .ui) -> some View {
        modifier(PerformanceMonitoringModifier(operation: operation, category: category))
    }
}

// MARK: - Performance Dashboard View
struct PerformanceDashboard: View {
    @ObservedObject private var monitor = PerformanceMonitor.shared
    @State private var selectedCategory: MetricCategory = .general
    
    private var filteredMetrics: [PerformanceMetric] {
        monitor.metrics.filter { $0.category == selectedCategory }
    }
    
    private var averageTime: TimeInterval {
        guard !filteredMetrics.isEmpty else { return 0 }
        return filteredMetrics.reduce(0) { $0 + $1.duration } / Double(filteredMetrics.count)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Monitoring status
                HStack {
                    Circle()
                        .fill(monitor.isMonitoring ? Color.green : Color.red)
                        .frame(width: 12, height: 12)
                    
                    Text(monitor.isMonitoring ? "Monitoring Active" : "Monitoring Inactive")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button(monitor.isMonitoring ? "Stop" : "Start") {
                        if monitor.isMonitoring {
                            monitor.stopMonitoring()
                        } else {
                            monitor.startMonitoring()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal)
                
                // Category selector
                Picker("Category", selection: $selectedCategory) {
                    ForEach(MetricCategory.allCases, id: \.self) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Summary stats
                HStack(spacing: 20) {
                    StatCard(
                        title: "Total Operations",
                        value: "\(filteredMetrics.count)",
                        color: .blue
                    )
                    
                    StatCard(
                        title: "Average Time",
                        value: "\(String(format: "%.1f", averageTime * 1000))ms",
                        color: .green
                    )
                    
                    StatCard(
                        title: "Slow Operations",
                        value: "\(monitor.getSlowOperations().count)",
                        color: .orange
                    )
                }
                .padding(.horizontal)
                
                // Metrics list
                List(filteredMetrics.reversed()) { metric in
                    MetricRow(metric: metric)
                }
                
                Spacer()
            }
            .navigationTitle("Performance")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu("Actions") {
                        Button("Clear Metrics") {
                            monitor.clearMetrics()
                        }
                        
                        Button("Export CSV") {
                            // In a real app, you'd share the CSV data
                            let csvData = monitor.exportMetrics()
                            print(csvData)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Stat Card Component
struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - Metric Row Component
struct MetricRow: View {
    let metric: PerformanceMetric
    
    private var isSlowOperation: Bool {
        metric.duration > 1.0
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(metric.operation)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(metric.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(String(format: "%.1f", metric.durationInMilliseconds))ms")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isSlowOperation ? .orange : .primary)
                
                if isSlowOperation {
                    Text("SLOW")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color.orange)
                        )
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Performance Timing Functions
func measureTime<T>(operation: String, category: MetricCategory = .general, _ block: () throws -> T) rethrows -> T {
    let monitor = PerformanceMonitor.shared
    Task { @MainActor in
        await monitor.startTimer(for: operation)
    }
    
    defer {
        Task { @MainActor in
            await monitor.endTimer(for: operation, category: category)
        }
    }
    
    return try block()
}

func measureTimeAsync<T>(operation: String, category: MetricCategory = .general, _ block: () async throws -> T) async rethrows -> T {
    let monitor = await PerformanceMonitor.shared
    await monitor.startTimer(for: operation)
    
    defer {
        Task { @MainActor in
            await monitor.endTimer(for: operation, category: category)
        }
    }
    
    return try await block()
}