import Foundation
import Combine
import os.log

// MARK: - Explore View Model
@MainActor
final class ExploreViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var charities: [CharityModel] = []
    @Published private(set) var filteredCharities: [CharityModel] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published var searchText = ""
    @Published var selectedCategory: String?
    
    // MARK: - Private Properties
    private let apiService = CharityAPIService()
    private let logger = Logger(subsystem: "com.whydonate.explore", category: "ExploreVM")
    private var cancellables = Set<AnyCancellable>()
    private var currentPage = 1
    private var hasMoreData = true
    
    // MARK: - Computed Properties
    var availableCategories: [String] {
        Array(Set(charities.compactMap { $0.category })).sorted()
    }
    
    // MARK: - Initialization
    init() {
        setupSearchDebouncing()
        loadCharities()
    }
    
    // MARK: - Public Methods
    func loadCharities() {
        Task {
            await fetchCharities()
        }
    }
    
    func refreshCharities() {
        currentPage = 1
        hasMoreData = true
        charities = []
        Task {
            await fetchCharities()
        }
    }
    
    func loadMoreCharities() {
        guard hasMoreData && !isLoading else { return }
        currentPage += 1
        Task {
            await fetchCharities()
        }
    }
    
    func clearFilters() {
        searchText = ""
        selectedCategory = nil
        applyFilters()
    }
    
    func selectCategory(_ category: String?) {
        selectedCategory = category
        applyFilters()
    }
    
    // MARK: - Private Methods
    private func fetchCharities() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let newCharities = try await apiService.fetchCharities(
                page: self.currentPage,
                pageSize: 20,
                searchTerm: searchText.isEmpty ? nil : searchText
            )
            
            if self.currentPage == 1 {
                charities = newCharities
            } else {
                charities.append(contentsOf: newCharities)
            }
            
            hasMoreData = newCharities.count == 20
            applyFilters()
            
            logger.info("Loaded \(newCharities.count) charities for page \(self.currentPage)")
            
        } catch {
            logger.error("Failed to fetch charities: \(error.localizedDescription)")
            errorMessage = "Failed to load charities. Please try again."
        }
        
        isLoading = false
    }
    
    private func setupSearchDebouncing() {
        $searchText
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.applyFilters()
            }
            .store(in: &cancellables)
    }
    
    private func applyFilters() {
        var filtered = self.charities
        
        // Apply category filter
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Apply search filter (if not already applied via API)
        if !searchText.isEmpty {
            filtered = filtered.filter { charity in
                charity.name.localizedCaseInsensitiveContains(self.searchText) ||
                charity.description.localizedCaseInsensitiveContains(self.searchText) ||
                charity.category.localizedCaseInsensitiveContains(self.searchText) == true
            }
        }
        
        filteredCharities = filtered
        logger.info("Applied filters: \(filtered.count) charities shown")
    }
} 
