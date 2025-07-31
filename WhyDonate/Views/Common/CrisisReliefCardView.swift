import SwiftUI

struct CrisisReliefCardView: View {
    let title: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: "flame.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .padding()
                .background(Color.red.opacity(0.2))
                .cornerRadius(10)

            Text(title)
                .font(.subheadline)
                .bold()

            Text(description)
                .font(.caption)
                .foregroundColor(.gray)
                .lineLimit(2)
        }
        .frame(width: 180)
        .padding()
        .background(Color.crisisCardBackground)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
// You can create a custom background color that complements the HomeView gradient.
// For example, use a soft blue/teal with some opacity for subtlety.

extension Color {
    static let crisisCardBackground = Color(red: 0.90, green: 0.95, blue: 1.0, opacity: 0.7)
}
 
// Optionally, you could provide a preview to visualize the effect:
struct CrisisReliefCardView_Previews: PreviewProvider {
    static var previews: some View {
        CrisisReliefCardView(
            title: "Wildfire Relief",
            description: "Support communities affected by wildfires."
        )
        .background(Color.clear) // To show the card's own background only
        .previewLayout(.sizeThatFits)
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.2, blue: 0.4),
                    Color(red: 0.0, green: 0.3, blue: 0.4),
                    Color(red: 0.95, green: 0.97, blue: 0.98)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}
 
// To use the new background, update the .background modifier in the main view above to:
// .background(Color.crisisCardBackground)
