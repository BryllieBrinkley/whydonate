import SwiftUI

struct UrgentNeedsSection: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Urgent Needs / Crisis Relief")
                .font(.headline)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    // Replace with real data
                    ForEach(1..<4) { index in
                        CrisisReliefCardView(
                            title: "Wildfire Relief \(index)",
                            description: "Support communities affected by wildfires."
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
