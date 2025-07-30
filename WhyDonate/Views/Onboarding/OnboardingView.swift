import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        TabView(selection: $currentPage) {
            OnboardingPage(
                title: "Welcome to WhyDonate",
                description: "Discover and support verified charities you trust.",
                systemImageName: "heart.fill"
            )
            .tag(0)

            OnboardingPage(
                title: "Make an Impact",
                description: "Track your donations and see your giving history.",
                systemImageName: "clock.fill"
            )
            .tag(1)

            FinalOnboardingPage {
                hasSeenOnboarding = true
            }
            .tag(2)
        }
        .tabViewStyle(PageTabViewStyle())
    }
}

