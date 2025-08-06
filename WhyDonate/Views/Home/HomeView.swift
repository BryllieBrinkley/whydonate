import SwiftUI

struct HomeView: View {
    // Use shared instance for better performance
    @ObservedObject private var viewModel = CharityViewModel.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: DesignSystem.Spacing.sectionSpacing) {
                    if viewModel.isLoading && viewModel.allCharities.isEmpty {
                        // Loading state for initial load
                        loadingStateView
                    } else {
                        // Main content sections
                        SuggestedByCauseSection(viewModel: viewModel)
                        
                        if !viewModel.urgentCharities.isEmpty {
                            UrgentNeedsSection(charities: viewModel.urgentCharities)
                        }
                        
                        if !viewModel.featuredCharities.isEmpty {
                            FeaturedCharitiesSection(viewModel: viewModel)
                        }
                        
                        if !viewModel.localCharities.isEmpty {
                            LocalCharitiesSection(charities: viewModel.localCharities)
                        }
                        
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
                .padding(.vertical, DesignSystem.Spacing.md)
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await viewModel.refreshData()
            }
            .task {
                // Load data on appear if needed
                if viewModel.allCharities.isEmpty && !viewModel.isLoading {
                    await viewModel.refreshData()
                }
            }
        }
    }
    
    // MARK: - Loading State View
    private var loadingStateView: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Spacer()
            
            // Animated loading indicator
            VStack(spacing: DesignSystem.Spacing.md) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(DesignSystem.Colors.primary)
                
                Text("Loading charities...")
                    .font(DesignSystem.Typography.subheadline)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
            .frame(maxWidth: .infinity, minHeight: 200)
            
            Spacer()
        }
    }
}

// MARK: - Error View Component
struct ErrorView: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Error icon
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(DesignSystem.Colors.warning)
            
            // Error text
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text("Something went wrong")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                
                Text(message)
                    .font(DesignSystem.Typography.subheadline)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                    .multilineTextAlignment(.center)
            }
            
            // Retry button
            Button("Try Again") {
                retryAction()
            }
            .primaryButtonStyle()
        }
        .padding(DesignSystem.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                .fill(DesignSystem.Colors.secondaryBackground)
        )
        .padding(.horizontal, DesignSystem.Spacing.md)
    }
}

// MARK: - Preview
#Preview {
    HomeView()
}
