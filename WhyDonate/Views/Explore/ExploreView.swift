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
                VStack(spacing: 16) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search charities...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                        
                        if !searchText.isEmpty {
                            Button("Clear") {
                                searchText = ""
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                    
                    // Category filters
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 12) {
                            ForEach(categories, id: \.self) { category in
                                CategoryFilterButton(
                                    category: category,
                                    isSelected: selectedCategory == category || (selectedCategory == nil && category == "All"),
                                    action: {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            selectedCategory = category == "All" ? nil : category
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .scrollClipDisabled()
                }
                .padding(.vertical, 16)
                .background(Color(.systemBackground))
                
                // Results section
                if viewModel.isLoading && viewModel.allCharities.isEmpty {
                    // Loading state
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Loading charities...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if filteredCharities.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: searchText.isEmpty ? "building.2.crop.circle" : "magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        
                        Text(searchText.isEmpty ? "No charities available" : "No results found")
                            .font(.headline)
                        
                        Text(searchText.isEmpty ? "Check back later for more charities" : "Try adjusting your search or filters")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        if !searchText.isEmpty {
                            Button("Clear Search") {
                                searchText = ""
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    // Results grid
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            ForEach(filteredCharities) { charity in
                                NavigationLink(destination: CharityDetailView(charity: charity)) {
                                    CharityCardView(charity: charity)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        await viewModel.refreshData()
                    }
                }
                
                Spacer(minLength: 0)
            }
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
}

// MARK: - Category Filter Button Component
struct CategoryFilterButton: View {
    let category: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(category)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .blue)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? Color.blue : Color.blue.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.blue, lineWidth: isSelected ? 0 : 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

// MARK: - Preview
#Preview {
    ExploreView()
}

