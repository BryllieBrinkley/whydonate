import SwiftUI

struct HomeView: View {
    // Use shared instance for better performance
    @ObservedObject private var viewModel = CharityViewModel.shared
    
    var body: some View {
        CompatibleNavigationStack {
            ScrollView {
                LazyVStack(spacing: 24) {
                    if viewModel.isLoading && viewModel.allCharities.isEmpty {
                        // Loading state for initial load
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("Loading charities...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, minHeight: 200)
                    } else {
                        // Main content sections
                        if !viewModel.urgentCharities.isEmpty {
                            UrgentNeedsSection(charities: viewModel.urgentCharities)
                        }
                        
                        if !viewModel.featuredCharities.isEmpty {
                            FeaturedCharitiesSection(viewModel: viewModel)
                        }
                        
                        if !viewModel.localCharities.isEmpty {
                            LocalCharitiesSection(charities: viewModel.localCharities)
                        }
                        
                        SuggestedByCauseSection(viewModel: viewModel)
                        
                        // Error state
                        if let errorMessage = viewModel.errorMessage {
                            ErrorView(message: errorMessage) {
                                Task {
                                    await viewModel.refreshData()
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 16)
            }
            .navigationTitle("Home")
            .compatibleRefreshable {
                await viewModel.refreshData()
            }
            .compatibleTask {
                // Load data on appear if needed
                if viewModel.allCharities.isEmpty && !viewModel.isLoading {
                    await viewModel.refreshData()
                }
            }
        }
    }
}

// MARK: - Error View Component
struct ErrorView: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.orange)
            
            Text("Something went wrong")
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Try Again") {
                retryAction()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .padding(.horizontal)
    }
}

// MARK: - Preview
#Preview {
    HomeView()
}
