import Foundation
import os.log

// MARK: - Home View Model
@MainActor
final class HomeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var featuredCharities: [CharityModel] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    
    // MARK: - Private Properties
    private let logger = Logger(subsystem: "com.whydonate.home", category: "HomeVM")
    
    // MARK: - Initialization
    init() {
        loadFeaturedCharities()
    }
    
    // MARK: - Public Methods
    func loadFeaturedCharities() {
        isLoading = true
        errorMessage = nil
        
        // Load a curated list of featured charities for the home screen
        featuredCharities = [
            CharityModel(
                name: "St. Jude Children's Research Hospital",
                description: "Leading pediatric treatment and research facility",
                imageName: "st-jude",
                category: "Healthcare",
                isUrgent: false,
                donationGoal: 1000000,
                amountRaised: 750000,
                location: "Memphis, TN",
                website: "https://www.stjude.org"
            ),
            CharityModel(
                name: "American Red Cross",
                description: "Humanitarian organization providing emergency assistance",
                imageName: "red-cross",
                category: "Disaster Relief",
                isUrgent: true,
                donationGoal: 500000,
                amountRaised: 300000,
                location: "Washington, DC",
                website: "https://www.redcross.org"
            ),
            CharityModel(
                name: "Feeding America",
                description: "National hunger relief organization",
                imageName: "feeding-america",
                category: "Human Services",
                isUrgent: false,
                donationGoal: 750000,
                amountRaised: 600000,
                location: "Chicago, IL",
                website: "https://www.feedingamerica.org"
            )
        ]
        
        isLoading = false
        logger.info("Loaded \(self.featuredCharities.count) featured charities")
    }
    
    func refreshFeaturedCharities() {
        loadFeaturedCharities()
    }
} 