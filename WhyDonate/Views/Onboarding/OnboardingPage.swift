import SwiftUI

struct OnboardingPage: View {
    let title: String
    let description: String
    let systemImageName: String
    let accentColor: Color
    
    @State private var iconScale: CGFloat = 0.8
    @State private var textOpacity: Double = 0.0

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Spacer()
            
            // Icon with animation
            Image(systemName: systemImageName)
                .font(.system(size: 80, weight: .medium))
                .foregroundColor(.white)
                .scaleEffect(iconScale)
                .onAppear {
                    withAnimation(DesignSystem.Animation.spring) {
                        iconScale = 1.0
                    }
                }
            
            // Text content
            VStack(spacing: DesignSystem.Spacing.md) {
                Text(title)
                    .font(DesignSystem.Typography.displayTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .opacity(textOpacity)
                
                Text(description)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                    .opacity(textOpacity)
            }
            .onAppear {
                withAnimation(DesignSystem.Animation.standard.delay(0.3)) {
                    textOpacity = 1.0
                }
            }
            
            Spacer()
        }
        .padding(DesignSystem.Spacing.lg)
    }
}

// MARK: - Preview
#Preview {
    OnboardingPage(
        title: "Welcome to WhyDonate",
        description: "Discover and support verified charities you trust.",
        systemImageName: "heart.fill",
        accentColor: DesignSystem.Colors.secondary
    )
    .background(DesignSystem.Colors.primaryGradient)
}
