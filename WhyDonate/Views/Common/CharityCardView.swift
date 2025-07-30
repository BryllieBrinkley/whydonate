import SwiftUI

struct CharityCardView: View {
    let charity: CharityModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: charity.imageName)
                .resizable()
                .frame(width: 60, height: 60)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)

            Text(charity.name)
                .font(.subheadline)
                .bold()

            Text(charity.description)
                .font(.caption)
                .lineLimit(2)
                .foregroundColor(.gray)
        }
        .frame(width: 180)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
