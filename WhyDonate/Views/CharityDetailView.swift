import SwiftUI

struct CharityDetailView: View {
    let charity: CharityModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(charity.name)
                    .font(.largeTitle)
                    .bold()

                Text(charity.description)
                    .font(.body)

                Button(action: {
                    // Donation logic
                }) {
                    Text("Donate Now")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .navigationTitle("Charity Details")
    }
}
