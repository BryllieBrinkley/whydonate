import SwiftUI

// MARK: - iOS Version Compatibility Extensions
extension View {
    /// Conditionally applies scrollClipDisabled for iOS 17+
    @ViewBuilder
    func conditionalScrollClipDisabled() -> some View {
        if #available(iOS 17.0, *) {
            self.scrollClipDisabled()
        } else {
            self
        }
    }
    
    /// Conditionally applies containerRelativeFrame for iOS 17+
    @ViewBuilder
    func conditionalContainerRelativeFrame(_ axes: Axis.Set, count: Int = 1, span: Int = 1, spacing: CGFloat = 0) -> some View {
        if #available(iOS 17.0, *) {
            self.containerRelativeFrame(axes, count: count, span: span, spacing: spacing)
        } else {
            self
        }
    }
    
    /// Conditionally applies task modifier for iOS 15+
    @ViewBuilder
    func compatibleTask(priority: TaskPriority = .userInitiated, _ action: @escaping () async -> Void) -> some View {
        if #available(iOS 15.0, *) {
            self.task(priority: priority, action)
        } else {
            self.onAppear {
                Task(priority: priority) {
                    await action()
                }
            }
        }
    }
    
    /// Conditionally applies refreshable modifier for iOS 15+
    @ViewBuilder
    func compatibleRefreshable(action: @escaping () async -> Void) -> some View {
        if #available(iOS 15.0, *) {
            self.refreshable(action: action)
        } else {
            self // No pull-to-refresh on older iOS versions
        }
    }
}

// MARK: - Button Style Compatibility
struct PlainButtonStyleCompat: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Progress View Style Compatibility
struct LinearProgressViewStyleCompat: ProgressViewStyle {
    let tint: Color
    
    func makeBody(configuration: Configuration) -> some View {
        if #available(iOS 15.0, *) {
            ProgressView(configuration)
                .progressViewStyle(LinearProgressViewStyle(tint: tint))
        } else {
            ProgressView(configuration)
                .progressViewStyle(LinearProgressViewStyle())
                .accentColor(tint)
        }
    }
}

extension ProgressViewStyle where Self == LinearProgressViewStyleCompat {
    static func tinted(_ color: Color) -> LinearProgressViewStyleCompat {
        LinearProgressViewStyleCompat(tint: color)
    }
}

// MARK: - Navigation Compatibility
struct CompatibleNavigationStack<Content: View>: View {
    let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack(root: content)
        } else {
            NavigationView(content: content)
                .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}

// MARK: - Async Compatibility
extension Task where Success == Never, Failure == Never {
    /// Sleep for a duration, compatible with older iOS versions
    static func compatibleSleep(seconds: Double) async throws {
        if #available(iOS 15.0, *) {
            try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
        } else {
            await withCheckedContinuation { continuation in
                DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                    continuation.resume()
                }
            }
        }
    }
}