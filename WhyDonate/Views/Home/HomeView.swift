import SwiftUI

struct HomeView: View {
    @StateObject var viewModel = CharityViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    UrgentNeedsSection()
                    FeaturedCharitiesSection(viewModel: viewModel)
                    LocalCharitiesSection()
                    SuggestedByCauseSection()
                }
                .padding(.vertical)
            }
            .navigationTitle("Home")
        }
    }
}
