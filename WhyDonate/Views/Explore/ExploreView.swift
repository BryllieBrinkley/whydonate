import SwiftUI

struct ExploreView: View {
    @ObservedObject private var viewModel = CharityViewModel.shared
    @State private var searchText = ""
    @State private var selectedCategory: String? = nil
    @State private var showingFilters = false
    
    private let categories = ["All", "Health", "Animals", "Environment", "Education", "Children", "Emergency", "Community", "Housing"]
    
    private var filteredCharities: [CharityModel] {
        let searchResults = searchText.isEmpty ? viewModel.allCharities : viewModel.searchCharities(query: searchText)
        
        if let selectedCategory = selectedCategory, selectedCategory != "All" {
            return searchResults.filter { $0.category == selectedCategory }
        }
        
        return searchResults
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search and filter header
                VStack(spacing: DesignSystem.Spacing.md) {
                    // Search bar
                    searchBar
                    
                    // Category filters
                    categoryFilters
                }
                .padding(.vertical, DesignSystem.Spacing.md)
                .background(DesignSystem.Colors.background)
                
                // Results section
                resultsSection
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle("Explore")
            .navigationBarTitleDisplayMode(.large)
            .task {
                // Load data on appear if needed
                if viewModel.allCharities.isEmpty && !viewModel.isLoading {
                    await viewModel.refreshData()
                }
            }
        }
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(DesignSystem.Colors.secondaryText)
            
            TextField("Search charities...", text: $searchText)
                .font(DesignSystem.Typography.body)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !searchText.isEmpty {
                Button("Clear") {
                    withAnimation(DesignSystem.Animation.quick) {
                        searchText = ""
                    }
                }
                .font(DesignSystem.Typography.caption1)
                .fontWeight(.medium)
                .foregroundColor(DesignSystem.Colors.primary)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .fill(DesignSystem.Colors.secondaryBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .stroke(DesignSystem.Colors.cardBorder, lineWidth: 0.5)
                )
        )
        .padding(.horizontal, DesignSystem.Spacing.md)
    }
    
    // MARK: - Category Filters
    private var categoryFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(categories, id: \.self) { category in
                    CategoryFilterButton(
                        category: category,
                        isSelected: selectedCategory == category || (selectedCategory == nil && category == "All"),
                        action: {
                            withAnimation(DesignSystem.Animation.quick) {
                                selectedCategory = category == "All" ? nil : category
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
        }
        .scrollClipDisabled()
    }
    
    // MARK: - Results Section
    private var resultsSection: some View {
        Group {
            if viewModel.isLoading && viewModel.allCharities.isEmpty {
                // Loading state
                loadingStateView
            } else if filteredCharities.isEmpty {
                // Empty state
                emptyStateView
            } else {
                // Results grid
                resultsGridView
            }
        }
    }
    
    // MARK: - Loading State View
    private var loadingStateView: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Spacer()
            
            VStack(spacing: DesignSystem.Spacing.md) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(DesignSystem.Colors.primary)
                
                Text("Loading charities...")
                    .font(DesignSystem.Typography.subheadline)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Spacer()
        }
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Spacer()
            
            VStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: searchText.isEmpty ? "building.2.crop.circle" : "magnifyingglass")
                    .font(.system(size: 48))
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                
                VStack(spacing: DesignSystem.Spacing.sm) {
                    Text(searchText.isEmpty ? "No charities available" : "No results found")
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                    
                    Text(searchText.isEmpty ? "Check back later for more charities" : "Try adjusting your search or filters")
                        .font(DesignSystem.Typography.subheadline)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                }
                
                if !searchText.isEmpty {
                    Button("Clear Search") {
                        withAnimation(DesignSystem.Animation.quick) {
                            searchText = ""
                        }
                    }
                    .primaryButtonStyle()
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            
            Spacer()
        }
    }
    
    // MARK: - Results Grid View
    private var resultsGridView: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: DesignSystem.Spacing.md),
                GridItem(.flexible(), spacing: DesignSystem.Spacing.md)
            ], spacing: DesignSystem.Spacing.md) {
                ForEach(filteredCharities) { charity in
                    NavigationLink(destination: CharityDetailView(charity: charity)) {
                        CharityCardView(charity: charity)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(DesignSystem.Spacing.md)
        }
        .refreshable {
            await viewModel.refreshData()
        }
    }
}

// MARK: - Category Filter Button Component
struct CategoryFilterButton: View {
    let category: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(category)
                .font(DesignSystem.Typography.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : DesignSystem.Colors.primary)
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                        .fill(isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.primary.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                        .stroke(DesignSystem.Colors.primary, lineWidth: isSelected ? 0 : 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(DesignSystem.Animation.quick, value: isSelected)
    }
}

// MARK: - Preview
#Preview {
    ExploreView()
}

