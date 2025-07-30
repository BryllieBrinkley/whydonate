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
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
