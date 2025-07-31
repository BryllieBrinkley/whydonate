import SwiftUI

struct ExploreView: View {
    @StateObject private var viewModel = ExploreViewModel()
    @State private var showingFilters = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Improved background with better contrast
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.98, green: 0.99, blue: 1.0), // Very light blue
                        Color(red: 0.95, green: 0.97, blue: 0.99)  // Light blue
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Enhanced search and filter bar
                    searchAndFilterBar
                    
                    // Content with improved spacing
                    if viewModel.isLoading {
                        loadingView
                    } else if let errorMessage = viewModel.errorMessage {
                        errorView(message: errorMessage)
                    } else if viewModel.filteredCharities.isEmpty {
                        emptyStateView
                    } else {
                        charityListView
                    }
                }
            }
            .navigationTitle("Explore Charities")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: viewModel.refreshCharities) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 18, weight: .medium))
                            Text("Refresh")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Enhanced Search and Filter Bar
    private var searchAndFilterBar: some View {
        VStack(spacing: 16) {
            // Improved search bar with better contrast
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
                
                TextField("Search charities by name, mission, or category...", text: $viewModel.searchText)
                    .font(.system(size: 16, weight: .regular))
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !viewModel.searchText.isEmpty {
                    Button(action: { viewModel.searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
            )
            
            // Enhanced filter chips with better spacing
            if !viewModel.availableCategories.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Filter by Category")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
                        .padding(.horizontal, 20)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            // All categories chip
                            FilterChip(
                                title: "All Categories",
                                isSelected: viewModel.selectedCategory == nil,
                                action: { viewModel.selectedCategory = nil }
                            )
                            
                            // Category chips
                            ForEach(viewModel.availableCategories, id: \.self) { category in
                                FilterChip(
                                    title: category,
                                    isSelected: viewModel.selectedCategory == category,
                                    action: { viewModel.selectedCategory = category }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }
    
    // MARK: - Enhanced Charity List View
    private var charityListView: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(viewModel.filteredCharities) { charity in
                    CharityListItemView(charity: charity)
                        .padding(.horizontal, 16)
                        .transition(.opacity.combined(with: .scale))
                }
            }
            .padding(.vertical, 20)
        }
        .refreshable {
            viewModel.refreshCharities()
        }
    }
    
    // MARK: - Enhanced Loading View
    private var loadingView: some View {
        VStack(spacing: 24) {
            ProgressView()
                .scaleEffect(1.4)
                .tint(Color(red: 0.1, green: 0.2, blue: 0.4))
            
            VStack(spacing: 8) {
                Text("Loading Verified Charities")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
                
                Text("We're fetching the latest charity data for you")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
    }
    
    // MARK: - Enhanced Error View
    private func errorView(message: String) -> some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 56, weight: .medium))
                .foregroundColor(.orange)
            
            VStack(spacing: 12) {
                Text("Something went wrong")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
                
                Text(message)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            
            Button(action: viewModel.refreshCharities) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16, weight: .medium))
                    Text("Try Again")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(red: 0.1, green: 0.2, blue: 0.4))
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Enhanced Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 56, weight: .medium))
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                Text("No charities found")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
                
                Text("Try adjusting your search terms or category filters to find what you're looking for")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            
            if !viewModel.searchText.isEmpty || viewModel.selectedCategory != nil {
                Button(action: viewModel.clearFilters) {
                    HStack(spacing: 8) {
                        Image(systemName: "xmark.circle")
                            .font(.system(size: 16, weight: .medium))
                        Text("Clear All Filters")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(red: 0.1, green: 0.2, blue: 0.4), lineWidth: 1.5)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Enhanced Filter Chip Component
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color(red: 0.1, green: 0.2, blue: 0.4) : Color.white)
                        .shadow(color: isSelected ? .black.opacity(0.1) : .black.opacity(0.05), radius: 2, x: 0, y: 1)
                )
                .foregroundColor(
                    isSelected ? .white : Color(red: 0.1, green: 0.2, blue: 0.4)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            isSelected ? Color.clear : Color(red: 0.1, green: 0.2, blue: 0.4).opacity(0.3),
                            lineWidth: 1.5
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

#Preview {
    ExploreView()
}

