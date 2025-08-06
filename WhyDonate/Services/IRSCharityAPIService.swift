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
    case invalidAPIKey
    case rateLimitExceeded
    
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
        case .invalidAPIKey:
            return "Invalid or missing API key"
        case .rateLimitExceeded:
            return "API rate limit exceeded. Please try again later."
        }
    }
}

// MARK: - Charity API Service
@MainActor
final class CharityAPIService: ObservableObject {
    private let logger = Logger(subsystem: "com.whydonate.api", category: "CharityAPI")
    
    // MARK: - Configuration
    private let baseURL = APIConfiguration.charityNavigatorBaseURL
    private let apiKey = APIConfiguration.currentAPIKey
    private let session: URLSession
    
    // MARK: - Published Properties
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var isUsingFallbackData = false
    
    // MARK: - Initialization
    init(session: URLSession = .shared) {
        self.session = session
        checkAPIKeyStatus()
    }
    
    // MARK: - Public Methods
    func fetchCharities(page: Int = 1, pageSize: Int = 20, searchTerm: String? = nil) async throws -> [CharityModel] {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        // Check if we have a valid API key
        guard APIConfiguration.isValidAPIKey(apiKey) else {
            logger.warning("Using fallback data - no valid API key configured")
            isUsingFallbackData = true
            return fallbackCharityData
        }
        
        do {
            let charities = try await performAPIRequest(page: page, pageSize: pageSize, searchTerm: searchTerm)
            logger.info("Successfully fetched \(charities.count) charities from API")
            isUsingFallbackData = false
            return charities
        } catch {
            logger.error("Failed to fetch charities from API: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            isUsingFallbackData = true
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
    
    // MARK: - API Key Management
    func checkAPIKeyStatus() {
        if !APIConfiguration.isValidAPIKey(apiKey) {
            logger.warning("No valid API key configured. Using fallback data.")
            isUsingFallbackData = true
        } else {
            logger.info("Valid API key configured")
            isUsingFallbackData = false
        }
    }
    
    func getAPIKeyStatus() -> (isValid: Bool, isUsingFallback: Bool) {
        let isValid = APIConfiguration.isValidAPIKey(apiKey)
        return (isValid, isUsingFallbackData)
    }
    
    // MARK: - Private Methods
    private func performAPIRequest(page: Int, pageSize: Int, searchTerm: String?) async throws -> [CharityModel] {
        guard let url = buildRequestURL(page: page, pageSize: pageSize, searchTerm: searchTerm) else {
            throw CharityAPIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        
        // Add headers from configuration
        let headers = APIConfiguration.headers(for: apiKey)
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        request.timeoutInterval = 30
        
        logger.info("Making API request to: \(url)")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw CharityAPIError.invalidResponse
        }
        
        // Handle different HTTP status codes
        switch httpResponse.statusCode {
        case 200:
            return try decodeCharities(from: data)
        case 401:
            throw CharityAPIError.invalidAPIKey
        case 429:
            throw CharityAPIError.rateLimitExceeded
        case 400...499:
            throw CharityAPIError.serverError(httpResponse.statusCode)
        case 500...599:
            throw CharityAPIError.serverError(httpResponse.statusCode)
        default:
            throw CharityAPIError.serverError(httpResponse.statusCode)
        }
    }
    
    private func buildRequestURL(page: Int, pageSize: Int, searchTerm: String?) -> URL? {
        var components = URLComponents(string: "\(baseURL)/organizations")
        var queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "pageSize", value: String(pageSize)),
            URLQueryItem(name: "app_id", value: apiKey),
            URLQueryItem(name: "app_key", value: apiKey)
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
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            // Note: This is a placeholder for the actual API response structure
            // You'll need to create proper response models based on the actual API
            logger.warning("Using fallback data - real API response structure not implemented")
            return fallbackCharityData
            
            // When you have the actual API response structure, uncomment and modify this:
            /*
            let response = try decoder.decode(CharityAPIResponse.self, from: data)
            return response.organizations.map { apiCharity in
                CharityModel(
                    name: apiCharity.name,
                    description: apiCharity.mission,
                    imageName: "building.2.crop.circle", // Default icon
                    category: apiCharity.category,
                    rating: apiCharity.rating,
                    isUrgent: false, // API doesn't provide this
                    verified: apiCharity.isVerified,
                    donationGoal: nil, // API doesn't provide this
                    amountRaised: nil, // API doesn't provide this
                    location: apiCharity.city + ", " + apiCharity.state,
                    website: apiCharity.website,
                    mission: apiCharity.mission,
                    ein: apiCharity.ein
                )
            }
            */
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
                category: "Healthcare",
                isUrgent: true,
                verified: true,
                donationGoal: 800000,
                amountRaised: 650000,
                location: "Memphis, TN",
                website: "https://www.stjude.org"
            ),
            CharityModel(
                name: "American Cancer Society",
                description: "Leading cancer research and support organization",
                imageName: "acs",
                category: "Healthcare",
                isUrgent: false,
                verified: true,
                donationGoal: 500000,
                amountRaised: 350000,
                location: "Atlanta, GA",
                website: "https://www.cancer.org"
            ),
            CharityModel(
                name: "Feeding America",
                description: "National hunger relief organization",
                imageName: "feeding-america",
                category: "Human Services",
                isUrgent: true,
                verified: true,
                donationGoal: 750000,
                amountRaised: 600000,
                location: "Chicago, IL",
                website: "https://www.feedingamerica.org"
            ),
            CharityModel(
                name: "Salvation Army",
                description: "International Christian charitable organization",
                imageName: "salvation-army",
                category: "Human Services",
                isUrgent: false,
                verified: true,
                donationGoal: 300000,
                amountRaised: 250000,
                location: "Alexandria, VA",
                website: "https://www.salvationarmy.org"
            ),
            CharityModel(
                name: "ASPCA",
                description: "American Society for the Prevention of Cruelty to Animals",
                imageName: "aspca",
                category: "Animal Welfare",
                isUrgent: false,
                verified: true,
                donationGoal: 400000,
                amountRaised: 320000,
                location: "New York, NY",
                website: "https://www.aspca.org"
            ),
            CharityModel(
                name: "Wounded Warrior Project",
                description: "Veterans service organization",
                imageName: "wwp",
                category: "Veterans",
                isUrgent: true,
                verified: true,
                donationGoal: 600000,
                amountRaised: 450000,
                location: "Jacksonville, FL",
                website: "https://www.woundedwarriorproject.org"
            ),
            CharityModel(
                name: "Metropolitan Museum of Art",
                description: "World-renowned art museum",
                imageName: "met",
                category: "Arts & Culture",
                isUrgent: false,
                verified: true,
                donationGoal: 200000,
                amountRaised: 180000,
                location: "New York, NY",
                website: "https://www.metmuseum.org"
            ),
            CharityModel(
                name: "United Way Worldwide",
                description: "Global network of local organizations working to improve lives",
                imageName: "united-way",
                category: "Human Services",
                isUrgent: false,
                verified: true,
                donationGoal: 800000,
                amountRaised: 650000,
                location: "Alexandria, VA",
                website: "https://www.unitedway.org"
            ),
            CharityModel(
                name: "Habitat for Humanity International",
                description: "Nonprofit housing organization",
                imageName: "habitat",
                category: "Human Services",
                isUrgent: true,
                verified: true,
                donationGoal: 900000,
                amountRaised: 700000,
                location: "Atlanta, GA",
                website: "https://www.habitat.org"
            )
        ]
    }
}

// MARK: - API Response Models (Placeholder)
/*
// Uncomment and modify these when you have the actual API response structure
struct CharityAPIResponse: Codable {
    let organizations: [APICharity]
    let totalCount: Int
    let page: Int
    let pageSize: Int
}

struct APICharity: Codable {
    let name: String
    let mission: String
    let category: String
    let rating: Double?
    let isVerified: Bool
    let city: String
    let state: String
    let website: String?
    let ein: String?
}
*/ 
