import Foundation

struct CharityModel: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let description: String
    let imageName: String
    let category: String
    let isUrgent: Bool
    let donationGoal: Double?
    let amountRaised: Double?
    let location: String?
    let website: String?
    
    // Computed properties for better performance
    var progress: Double {
        guard let goal = donationGoal, let raised = amountRaised, goal > 0 else { return 0 }
        return min(raised / goal, 1.0)
    }
    
    var isLocal: Bool {
        location != nil
    }
    
    // Default initializer for backward compatibility
    init(name: String, description: String, imageName: String, category: String = "General", isUrgent: Bool = false, donationGoal: Double? = nil, amountRaised: Double? = nil, location: String? = nil, website: String? = nil) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.imageName = imageName
        self.category = category
        self.isUrgent = isUrgent
        self.donationGoal = donationGoal
        self.amountRaised = amountRaised
        self.location = location
        self.website = website
    }
    
    // Hashable conformance for better performance in collections
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: CharityModel, rhs: CharityModel) -> Bool {
        lhs.id == rhs.id
    }
}
