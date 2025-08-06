import SwiftUI

struct UrgentNeedsSection: View {
    let charities: [CharityModel]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Urgent Needs / Crisis Relief")
                .font(.headline)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(charities) { charity in
                        NavigationLink(destination: CharityDetailView(charity: charity)) {
                            CrisisReliefCardView(
                                title: charity.name,
                                description: charity.description,
                                imageName: charity.imageName,
                                urgencyLevel: determineUrgencyLevel(for: charity),
                                donationGoal: charity.donationGoal,
                                amountRaised: charity.amountRaised
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // Add some sample crisis relief items if no urgent charities
                    if charities.isEmpty {
                        ForEach(sampleCrisisItems, id: \.title) { item in
                            CrisisReliefCardView(
                                title: item.title,
                                description: item.description,
                                imageName: item.imageName,
                                urgencyLevel: item.urgencyLevel,
                                donationGoal: item.donationGoal,
                                amountRaised: item.amountRaised
                            )
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 4)
            }
            .scrollClipDisabled()
        }
    }
    
    // MARK: - Helper Methods
    private func determineUrgencyLevel(for charity: CharityModel) -> CrisisReliefCardView.UrgencyLevel {
        if charity.category == "Emergency" {
            return .critical
        } else if charity.isUrgent {
            return .high
        } else {
            return .medium
        }
    }
    
    // MARK: - Sample Data
    private var sampleCrisisItems: [(title: String, description: String, imageName: String, urgencyLevel: CrisisReliefCardView.UrgencyLevel, donationGoal: Double, amountRaised: Double)] {
        [
            (
                title: "Wildfire Relief",
                description: "Support communities affected by devastating wildfires.",
                imageName: "flame.fill",
                urgencyLevel: .critical,
                donationGoal: 100000,
                amountRaised: 65000
            ),
            (
                title: "Hurricane Recovery",
                description: "Immediate aid for hurricane victims and rebuilding efforts.",
                imageName: "hurricane",
                urgencyLevel: .high,
                donationGoal: 150000,
                amountRaised: 75000
            ),
            (
                title: "Flood Emergency Response",
                description: "Clean water and shelter for flood-affected families.",
                imageName: "drop.fill",
                urgencyLevel: .high,
                donationGoal: 80000,
                amountRaised: 30000
            )
        ]
    }
}

// MARK: - Preview
#Preview {
    VStack {
        UrgentNeedsSection(charities: [
            CharityModel(
                name: "Emergency Relief Fund",
                description: "Providing immediate assistance to disaster-affected communities.",
                imageName: "exclamationmark.triangle.fill",
                category: "Emergency",
                isUrgent: true,
                donationGoal: 500000,
                amountRaised: 200000
            )
        ])
        
        UrgentNeedsSection(charities: [])
    }
}
