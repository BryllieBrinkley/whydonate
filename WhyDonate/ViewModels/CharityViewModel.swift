import Foundation
import SwiftUI

@MainActor
class CharityViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var featuredCharities: [CharityModel] = []
    @Published var localCharities: [CharityModel] = []
    @Published var urgentCharities: [CharityModel] = []
    @Published var allCharities: [CharityModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private var charitiesCache: [String: [CharityModel]] = [:]
    private var lastCacheUpdate: Date = Date.distantPast
    private let cacheValidityDuration: TimeInterval = 300 // 5 minutes
    
    // MARK: - Singleton Pattern for Performance
    static let shared = CharityViewModel()
    
    private init() {
        loadInitialData()
    }
    
    // MARK: - Public Methods
    func loadInitialData() {
        // Load from cache first if available
        if let cachedData = loadFromCache(), isCacheValid() {
            updateCharitiesFromCache(cachedData)
            return
        }
        
        // Otherwise load fresh data
        loadCharitiesData()
    }
    
    func refreshData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Simulate network delay and add realistic data
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            
            let newCharities = generateSampleCharities()
            
            await MainActor.run {
                self.allCharities = newCharities
                self.categorizeCharities()
                self.saveToCache(newCharities)
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to load charities: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func searchCharities(query: String) -> [CharityModel] {
        guard !query.isEmpty else { return allCharities }
        
        return allCharities.filter { charity in
            charity.name.localizedCaseInsensitiveContains(query) ||
            charity.description.localizedCaseInsensitiveContains(query) ||
            charity.category.localizedCaseInsensitiveContains(query)
        }
    }
    
    func getCharitiesByCategory(_ category: String) -> [CharityModel] {
        if let cached = charitiesCache[category] {
            return cached
        }
        
        let filtered = allCharities.filter { $0.category == category }
        charitiesCache[category] = filtered
        return filtered
    }
    
    // MARK: - Private Methods
    private func loadCharitiesData() {
        isLoading = true
        
        // Simulate async loading with realistic data
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let charities = self?.generateSampleCharities() ?? []
            
            Task { @MainActor in
                self?.allCharities = charities
                self?.categorizeCharities()
                self?.saveToCache(charities)
                self?.isLoading = false
            }
        }
    }
    
    private func categorizeCharities() {
        featuredCharities = Array(allCharities.prefix(6))
        urgentCharities = allCharities.filter { $0.isUrgent }
        localCharities = allCharities.filter { $0.isLocal }
    }
    
    private func generateSampleCharities() -> [CharityModel] {
        return [
            CharityModel(
                name: "St. Jude Children's Research Hospital",
                description: "Leading the way the world understands, treats and defeats childhood cancer.",
                imageName: "heart.fill",
                category: "Health",
                isUrgent: false,
                verified: true,
                donationGoal: 1000000,
                amountRaised: 750000,
                website: "https://stjude.org"
            ),
            CharityModel(
                name: "ASPCA",
                description: "The ASPCA works to rescue animals from abuse, pass humane laws and share resources.",
                imageName: "pawprint.fill",
                category: "Animals",
                isUrgent: false,
                verified: true,
                donationGoal: 500000,
                amountRaised: 320000
            ),
            CharityModel(
                name: "Feeding America",
                description: "Our mission is to advance change in America by ensuring equitable access to nutritious food.",
                imageName: "leaf.fill",
                category: "Hunger",
                isUrgent: true,
                verified: true,
                donationGoal: 2000000,
                amountRaised: 1200000
            ),
            CharityModel(
                name: "American Red Cross",
                description: "Preventing and alleviating human suffering in the face of emergencies.",
                imageName: "cross.fill",
                category: "Emergency",
                isUrgent: true,
                verified: true,
                donationGoal: 800000,
                amountRaised: 600000
            ),
            CharityModel(
                name: "Local Food Bank",
                description: "Supporting families in need within our local community.",
                imageName: "house.fill",
                category: "Community",
                isUrgent: false,
                verified: true,
                donationGoal: 100000,
                amountRaised: 65000,
                location: "Local Community"
            ),
            CharityModel(
                name: "Doctors Without Borders",
                description: "Providing medical aid where it's needed most, regardless of race, religion, or politics.",
                imageName: "stethoscope",
                category: "Health",
                isUrgent: true,
                verified: true,
                donationGoal: 1500000,
                amountRaised: 900000
            ),
            CharityModel(
                name: "World Wildlife Fund",
                description: "Building a future in which humans live in harmony with nature.",
                imageName: "globe",
                category: "Environment",
                isUrgent: false,
                verified: true,
                donationGoal: 750000,
                amountRaised: 400000
            ),
            CharityModel(
                name: "Habitat for Humanity",
                description: "Seeking to put God's love into action by bringing people together to build homes.",
                imageName: "hammer.fill",
                category: "Housing",
                isUrgent: false,
                verified: true,
                donationGoal: 600000,
                amountRaised: 350000
            )
        ]
    }
    
    // MARK: - Caching Methods
    private func saveToCache(_ charities: [CharityModel]) {
        do {
            let data = try JSONEncoder().encode(charities)
            UserDefaults.standard.set(data, forKey: "cached_charities")
            UserDefaults.standard.set(Date(), forKey: "cache_timestamp")
            lastCacheUpdate = Date()
        } catch {
            print("Failed to cache charities: \(error)")
        }
    }
    
    private func loadFromCache() -> [CharityModel]? {
        guard let data = UserDefaults.standard.data(forKey: "cached_charities"),
              let timestamp = UserDefaults.standard.object(forKey: "cache_timestamp") as? Date else {
            return nil
        }
        
        lastCacheUpdate = timestamp
        
        do {
            return try JSONDecoder().decode([CharityModel].self, from: data)
        } catch {
            print("Failed to decode cached charities: \(error)")
            return nil
        }
    }
    
    private func isCacheValid() -> Bool {
        Date().timeIntervalSince(lastCacheUpdate) < cacheValidityDuration
    }
    
    private func updateCharitiesFromCache(_ charities: [CharityModel]) {
        allCharities = charities
        categorizeCharities()
    }
}
