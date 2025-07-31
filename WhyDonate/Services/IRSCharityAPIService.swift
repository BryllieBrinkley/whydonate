import Foundation
import Combine
import os.log

// MARK: - API Error Types
enum CharityAPIError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case serverError(Int)
    case noData
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL configuration"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Data parsing error: \(error.localizedDescription)"
        case .serverError(let code):
            return "Server error: HTTP \(code)"
        case .noData:
            return "No data received from server"
        case .invalidResponse:
            return "Invalid response format"
        }
    }
}

// MARK: - Charity API Service
@MainActor
final class CharityAPIService: ObservableObject {
    private let logger = Logger(subsystem: "com.whydonate.api", category: "CharityAPI")
    
    // MARK: - Configuration
    private let baseURL = "https://api.charitynavigator.org/v2"
    private let apiKey = "demo_key" // TODO: Replace with production API key
    private let session: URLSession
    
    // MARK: - Published Properties
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    
    // MARK: - Initialization
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    // MARK: - Public Methods
    func fetchCharities(page: Int = 1, pageSize: Int = 20, searchTerm: String? = nil) async throws -> [CharityModel] {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        do {
            let charities = try await performAPIRequest(page: page, pageSize: pageSize, searchTerm: searchTerm)
            logger.info("Successfully fetched \(charities.count) charities")
            return charities
        } catch {
            logger.error("Failed to fetch charities: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            return fallbackCharityData
        }
    }
    
    func searchCharities(query: String) async throws -> [CharityModel] {
        return try await fetchCharities(searchTerm: query)
    }
    
    func getCharitiesByCategory(_ category: String) async throws -> [CharityModel] {
        let allCharities = try await fetchCharities()
        return allCharities.filter { $0.category == category }
    }
    
    // MARK: - Private Methods
    private func performAPIRequest(page: Int, pageSize: Int, searchTerm: String?) async throws -> [CharityModel] {
        guard let url = buildRequestURL(page: page, pageSize: pageSize, searchTerm: searchTerm) else {
            throw CharityAPIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw CharityAPIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw CharityAPIError.serverError(httpResponse.statusCode)
        }
        
        return try decodeCharities(from: data)
    }
    
    private func buildRequestURL(page: Int, pageSize: Int, searchTerm: String?) -> URL? {
        var components = URLComponents(string: "\(baseURL)/organizations")
        var queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "pageSize", value: String(pageSize))
        ]
        
        if let searchTerm = searchTerm, !searchTerm.isEmpty {
            queryItems.append(URLQueryItem(name: "search", value: searchTerm))
        }
        
        components?.queryItems = queryItems
        return components?.url
    }
    
    private func decodeCharities(from data: Data) throws -> [CharityModel] {
        do {
            let decoder = JSONDecoder()
            let apiResponse = try decoder.decode(CharityAPIResponse.self, from: data)
            return apiResponse.charities
        } catch {
            logger.error("Failed to decode charity data: \(error.localizedDescription)")
            throw CharityAPIError.decodingError(error)
        }
    }
    
    // MARK: - Fallback Data
    private var fallbackCharityData: [CharityModel] {
        [
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
                name: "American Cancer Society",
                description: "Leading cancer research and support organization",
                imageName: "acs",
                ein: "13-1788491",
                mission: "To save lives, celebrate lives, and lead the fight for a world without cancer.",
                category: "Healthcare",
                location: CharityLocation(city: "Atlanta", state: "GA", country: "USA", zipCode: "30329"),
                website: "https://www.cancer.org",
                rating: 4.7,
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
            ),
            CharityModel(
                name: "Salvation Army",
                description: "International Christian charitable organization",
                imageName: "salvation-army",
                ein: "22-1620800",
                mission: "To preach the gospel of Jesus Christ and to meet human needs in His name without discrimination.",
                category: "Human Services",
                location: CharityLocation(city: "Alexandria", state: "VA", country: "USA", zipCode: "22314"),
                website: "https://www.salvationarmy.org",
                rating: 4.1,
                verified: true
            ),
            CharityModel(
                name: "ASPCA",
                description: "American Society for the Prevention of Cruelty to Animals",
                imageName: "aspca",
                ein: "13-1623829",
                mission: "To provide effective means for the prevention of cruelty to animals throughout the United States.",
                category: "Animal Welfare",
                location: CharityLocation(city: "New York", state: "NY", country: "USA", zipCode: "10128"),
                website: "https://www.aspca.org",
                rating: 4.3,
                verified: true
            ),
            CharityModel(
                name: "Wounded Warrior Project",
                description: "Veterans service organization",
                imageName: "wwp",
                ein: "20-2370935",
                mission: "To honor and empower Wounded Warriors who incurred a physical or mental injury, illnesses, or wound, co-incident to your military service.",
                category: "Veterans",
                location: CharityLocation(city: "Jacksonville", state: "FL", country: "USA", zipCode: "32256"),
                website: "https://www.woundedwarriorproject.org",
                rating: 4.4,
                verified: true
            ),
            CharityModel(
                name: "Metropolitan Museum of Art",
                description: "World-renowned art museum",
                imageName: "met",
                ein: "13-1624088",
                mission: "To collect, preserve, study, exhibit, and stimulate appreciation for and advance knowledge of works of art.",
                category: "Arts & Culture",
                location: CharityLocation(city: "New York", state: "NY", country: "USA", zipCode: "10028"),
                website: "https://www.metmuseum.org",
                rating: 4.7,
                verified: true
            ),
            CharityModel(
                name: "United Way Worldwide",
                description: "Global network of local organizations working to improve lives",
                imageName: "united-way",
                ein: "13-1623888",
                mission: "To improve lives by mobilizing the caring power of communities around the world to advance the common good.",
                category: "Human Services",
                location: CharityLocation(city: "Alexandria", state: "VA", country: "USA", zipCode: "22314"),
                website: "https://www.unitedway.org",
                rating: 4.2,
                verified: true
            ),
            CharityModel(
                name: "Habitat for Humanity International",
                description: "Nonprofit housing organization",
                imageName: "habitat",
                ein: "58-1164669",
                mission: "To bring people together to build homes, communities and hope.",
                category: "Human Services",
                location: CharityLocation(city: "Atlanta", state: "GA", country: "USA", zipCode: "30309"),
                website: "https://www.habitat.org",
                rating: 4.3,
                verified: true
            )
        ]
    }
} 
