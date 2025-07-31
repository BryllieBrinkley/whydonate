import SwiftUI

struct HomeView: View {
    @StateObject var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.1, green: 0.2, blue: 0.4),
                        Color(red: 0.0, green: 0.3, blue: 0.4),
                        Color(red: 0.95, green: 0.97, blue: 0.98)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        
                        // Recommended Charities
                        SuggestedByCauseSection()
                        
                        // Why Donate section
                        WhyDonateSection()
                        
                        // Featured charities
                        FeaturedCharitiesSection(viewModel: viewModel)
                        
                        // Local charities
                        LocalCharitiesSection()
                        
                        // Urgent needs
                        UrgentNeedsSection()
                        
                    }
                    
                    .padding(.vertical)
                }
            }
            .navigationTitle("Home")
        }
    }
}
