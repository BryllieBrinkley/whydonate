import SwiftUI

struct CharityCardView: View {
    let charity: CharityModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with icon and urgency indicator
            HStack {
                Image(systemName: charity.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .foregroundColor(.blue)
                    .background(
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 60, height: 60)
                    )
                
                Spacer()
                
                if charity.isUrgent {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                }
            }
            
            // Charity information
            VStack(alignment: .leading, spacing: 4) {
                Text(charity.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text(charity.description)
                    .font(.caption)
                    .lineLimit(3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                
                if charity.location != nil {
                    HStack {
                        Image(systemName: "location.fill")
                            .font(.caption2)
                            .foregroundColor(.blue)
                        Text("Local")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            // Progress indicator if donation goals exist
            if charity.donationGoal != nil {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Progress")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(Int(charity.progress * 100))%")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    }
                    
                    ProgressView(value: charity.progress)
                        .progressViewStyle(.tinted(.blue))
                        .scaleEffect(y: 0.8)
                }
            }
        }
        .padding(16)
        .frame(width: 200, minHeight: 160)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        // Performance optimization: Stable identity for SwiftUI
        .id(charity.id)
        // Accessibility improvements
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(charity.name). \(charity.description)")
        .accessibilityHint(charity.isUrgent ? "Urgent charity" : "Tap to learn more")
    }
}

// MARK: - Preview
#Preview {
    HStack {
        CharityCardView(
            charity: CharityModel(
                name: "St. Jude Children's Hospital",
                description: "Leading the way the world understands, treats and defeats childhood cancer.",
                imageName: "heart.fill",
                category: "Health",
                donationGoal: 1000000,
                amountRaised: 750000
            )
        )
        
        CharityCardView(
            charity: CharityModel(
                name: "Emergency Relief Fund",
                description: "Providing immediate assistance to disaster-affected communities.",
                imageName: "exclamationmark.triangle.fill",
                category: "Emergency",
                isUrgent: true,
                donationGoal: 500000,
                amountRaised: 200000,
                location: "Local Community"
            )
        )
    }
    .padding()
}
