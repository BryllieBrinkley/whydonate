import Foundation

// Enhanced model for API charity data
struct CharityModel: Identifiable, Codable {
    let id = UUID()
    let name: String
    let description: String
    let imageName: String
    let ein: String?
    let mission: String?
    let category: String?
    let location: CharityLocation?
    let website: String?
    let rating: Double?
    let verified: Bool
    
    enum CodingKeys: String, CodingKey {
        case name, description, mission, category, website, rating, verified
        case ein = "EIN"
        case location
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        mission = try container.decodeIfPresent(String.self, forKey: .mission)
        category = try container.decodeIfPresent(String.self, forKey: .category)
        ein = try container.decodeIfPresent(String.self, forKey: .ein)
        website = try container.decodeIfPresent(String.self, forKey: .website)
        rating = try container.decodeIfPresent(Double.self, forKey: .rating)
        verified = try container.decodeIfPresent(Bool.self, forKey: .verified) ?? false
        location = try container.decodeIfPresent(CharityLocation.self, forKey: .location)
        imageName = "charity-placeholder" // Default placeholder
    }
    
    // Comprehensive initializer for API data
    init(name: String, description: String, imageName: String, ein: String?, mission: String?, category: String?, location: CharityLocation?, website: String?, rating: Double?, verified: Bool) {
        self.name = name
        self.description = description
        self.imageName = imageName
        self.ein = ein
        self.mission = mission
        self.category = category
        self.location = location
        self.website = website
        self.rating = rating
        self.verified = verified
    }
    
    // Convenience initializer for existing data
    init(name: String, description: String, imageName: String) {
        self.name = name
        self.description = description
        self.imageName = imageName
        self.mission = nil
        self.category = nil
        self.ein = nil
        self.website = nil
        self.rating = nil
        self.verified = false
        self.location = nil
    }
}

struct CharityLocation: Codable {
    let city: String?
    let state: String?
    let country: String?
    let zipCode: String?
    
    var displayAddress: String {
        var components: [String] = []
        if let city = city { components.append(city) }
        if let state = state { components.append(state) }
        if let zipCode = zipCode { components.append(zipCode) }
        return components.joined(separator: ", ")
    }
    
    init(city: String?, state: String?, country: String?, zipCode: String?) {
        self.city = city
        self.state = state
        self.country = country
        self.zipCode = zipCode
    }
}

// API Response models
struct CharityAPIResponse: Codable {
    let charities: [CharityModel]
    let totalCount: Int
    let page: Int
    let pageSize: Int
    
    enum CodingKeys: String, CodingKey {
        case charities = "data"
        case totalCount = "total_count"
        case page
        case pageSize = "page_size"
    }
}

struct APIError: Codable, Error {
    let message: String
    let code: String?
}
