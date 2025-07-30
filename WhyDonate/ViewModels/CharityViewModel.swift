import Foundation

class CharityViewModel: ObservableObject {
    @Published var featuredCharities: [CharityModel] = [
        CharityModel(name: "St. Jude’s", description: "Helping kids with cancer.", imageName: "heart.fill"),
        CharityModel(name: "ASPCA", description: "Protecting animals nationwide.", imageName: "pawprint.fill"),
        CharityModel(name: "Feeding America", description: "Fighting hunger in the U.S.", imageName: "leaf.fill")
    ]
}
