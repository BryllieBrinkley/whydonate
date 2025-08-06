import SwiftUI

struct LocalCharitiesSection: View {
    let charities: [CharityModel]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                        
                        Text("Local Charities")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    Text("Support organizations in your community")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("See All") {
                    // Navigate to all local charities
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            .padding(.horizontal)
            
            // Local charity cards with lazy loading
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(charities) { charity in
                        NavigationLink(destination: CharityDetailView(charity: charity)) {
                            CharityCardView(charity: charity)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // Add sample local charities if none available
                    if charities.isEmpty {
                        ForEach(sampleLocalCharities, id: \.name) { charity in
                            NavigationLink(destination: CharityDetailView(charity: charity)) {
                                CharityCardView(charity: charity)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 4)
            }
            .scrollClipDisabled()
        }
    }
    
    // MARK: - Sample Data
    private var sampleLocalCharities: [CharityModel] {
        [
            CharityModel(
                name: "Local Food Bank",
                description: "Providing meals to families in need within our community.",
                imageName: "house.fill",
                category: "Community",
                donationGoal: 50000,
                amountRaised: 32000,
                location: "Your City"
            ),
            CharityModel(
                name: "Community Youth Center",
                description: "After-school programs and mentorship for local youth.",
                imageName: "figure.walk",
                category: "Education",
                donationGoal: 75000,
                amountRaised: 45000,
                location: "Your City"
            ),
            CharityModel(
                name: "Senior Care Services",
                description: "Supporting elderly residents with daily care and companionship.",
                imageName: "heart.text.square",
                category: "Community",
                donationGoal: 60000,
                amountRaised: 38000,
                location: "Your City"
            )
        ]
    }
}

// MARK: - Preview
#Preview {
    VStack {
        LocalCharitiesSection(charities: [
            CharityModel(
                name: "Local Food Bank",
                description: "Supporting families in need within our local community.",
                imageName: "house.fill",
                category: "Community",
                donationGoal: 100000,
                amountRaised: 65000,
                location: "Local Community"
            )
        ])
        
        LocalCharitiesSection(charities: [])
    }
}
