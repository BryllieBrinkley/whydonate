import SwiftUI

struct LocalCharitiesSection: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Local Charities Near You")
                .font(.headline)
                .padding(.horizontal)

            VStack(alignment: .leading, spacing: 12) {
                // Replace with location-aware logic
                Text("Charlotte Animal Shelter")
                Text("Second Harvest Food Bank")
                Text("Hope House Foundation")
            }
            .padding(.horizontal)
            .font(.body)
        }
    }
}
