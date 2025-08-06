import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        ZStack {
            // Background gradient
            DesignSystem.Colors.primaryGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Page indicator
                HStack(spacing: DesignSystem.Spacing.sm) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.white : Color.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(index == currentPage ? 1.2 : 1.0)
                            .animation(DesignSystem.Animation.quick, value: currentPage)
                    }
                }
                .padding(.top, DesignSystem.Spacing.xl)
                .padding(.bottom, DesignSystem.Spacing.lg)
                
                // Page content
                TabView(selection: $currentPage) {
                    OnboardingPage(
                        title: "Welcome to WhyDonate",
                        description: "Discover and support verified charities you trust.",
                        systemImageName: "heart.fill",
                        accentColor: DesignSystem.Colors.secondary
                    )
                    .tag(0)

                    OnboardingPage(
                        title: "Make an Impact",
                        description: "Track your donations and see your giving history.",
                        systemImageName: "chart.line.uptrend.xyaxis",
                        accentColor: DesignSystem.Colors.accent
                    )
                    .tag(1)

                    FinalOnboardingPage {
                        hasSeenOnboarding = true
                    }
                    .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(DesignSystem.Animation.standard, value: currentPage)
                
                // Navigation buttons
                HStack(spacing: DesignSystem.Spacing.md) {
                    if currentPage > 0 {
                        Button("Back") {
                            withAnimation(DesignSystem.Animation.standard) {
                                currentPage -= 1
                            }
                        }
                        .secondaryButtonStyle()
                    }
                    
                    Spacer()
                    
                    Button(currentPage == 2 ? "Get Started" : "Next") {
                        withAnimation(DesignSystem.Animation.standard) {
                            if currentPage < 2 {
                                currentPage += 1
                            } else {
                                hasSeenOnboarding = true
                            }
                        }
                    }
                    .primaryButtonStyle()
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.bottom, DesignSystem.Spacing.xl)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    OnboardingView()
}

