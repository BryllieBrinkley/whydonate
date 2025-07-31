import SwiftUI

struct LocalCharitiesSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Local Charities Near You")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    CharityCard(charityName: "Charlotte Animal Shelter", description: "Provide safe havens for animals.")
                    CharityCard(charityName: "Second Harvest Food Bank", description: "Fighting hunger in your area.")
                    CharityCard(charityName: "Hope House Foundation", description: "Supporting families in need.")
                }
                .padding(.horizontal)
            }
        }
    }
}

struct CharityCard: View {
    var charityName: String
    var description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Replace with actual image or logo
            Image(systemName: "house")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .padding(.top)
            
            Text(charityName)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Button(action: {
                // Action for "Learn More"
            }) {
                Text("Learn More")
                    .font(.footnote)
                    .foregroundColor(.blue)
            }
            .padding(.top, 4)
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .shadow(radius: 2)
        .frame(width: 200) // Adjust width as needed
    }
}
