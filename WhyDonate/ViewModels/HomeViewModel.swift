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
                ein: "62-0646012",
                mission: "To advance cures, and means of prevention, for pediatric catastrophic diseases through research and treatment.",
                category: "Healthcare",
                location: CharityLocation(city: "Memphis", state: "TN", country: "USA", zipCode: "38105"),
                website: "https://www.stjude.org",
                rating: 4.9,
                verified: true
            ),
            CharityModel(
                name: "American Red Cross",
                description: "Humanitarian organization providing emergency assistance",
                imageName: "red-cross",
                ein: "53-0196605",
                mission: "To prevent and alleviate human suffering in the face of emergencies by mobilizing the power of volunteers and the generosity of donors.",
                category: "Disaster Relief",
                location: CharityLocation(city: "Washington", state: "DC", country: "USA", zipCode: "20006"),
                website: "https://www.redcross.org",
                rating: 4.5,
                verified: true
            ),
            CharityModel(
                name: "Feeding America",
                description: "National hunger relief organization",
                imageName: "feeding-america",
                ein: "36-3673599",
                mission: "To feed America's hungry through a nationwide network of member food banks.",
                category: "Human Services",
                location: CharityLocation(city: "Chicago", state: "IL", country: "USA", zipCode: "60601"),
                website: "https://www.feedingamerica.org",
                rating: 4.6,
                verified: true
            )
        ]
        
        isLoading = false
        logger.info("Loaded \(self.featuredCharities.count) featured charities")
    }
    
    func refreshFeaturedCharities() {
        loadFeaturedCharities()
    }
} 