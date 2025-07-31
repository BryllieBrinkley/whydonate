import SwiftUI

struct WhyDonateSection: View {
    @State private var selectedStatIndex = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Section header
            VStack(alignment: .leading, spacing: 8) {
                Text("Why Donate?")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
                
                Text("See the real impact of your generosity")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            
            // Impact statistics carousel
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(Array(ImpactStat.impactStats.enumerated()), id: \.element.id) { index, stat in
                        ImpactStatCard(
                            stat: stat,
                            isSelected: selectedStatIndex == index
                        ) {
                            selectedStatIndex = index
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            
            // Call to action
            VStack(spacing: 12) {
                Text("Every donation makes a difference")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
                    .multilineTextAlignment(.center)
                
                Text("Join thousands of donors making an impact")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Button(action: {
                    // Navigate to explore charities
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 16, weight: .medium))
                        Text("Start Donating")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(red: 0.1, green: 0.2, blue: 0.4))
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.1, green: 0.2, blue: 0.4).opacity(0.05))
            )
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Impact Stat Card
struct ImpactStatCard: View {
    let stat: ImpactStat
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Icon
                Image(systemName: stat.icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(isSelected ? .white : Color(red: 0.1, green: 0.2, blue: 0.4))
                    .frame(width: 48, height: 48)
                    .background(
                        Circle()
                            .fill(isSelected ? Color(red: 0.1, green: 0.2, blue: 0.4) : Color(red: 0.1, green: 0.2, blue: 0.4).opacity(0.1))
                    )
                
                // Value
                Text(stat.value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(isSelected ? .white : Color(red: 0.1, green: 0.2, blue: 0.4))
                
                // Title
                Text(stat.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isSelected ? .white.opacity(0.9) : Color(red: 0.1, green: 0.2, blue: 0.4))
                    .multilineTextAlignment(.center)
                
                // Description
                Text(stat.description)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? .white.opacity(0.7) : .secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(16)
            .frame(width: 140, height: 160)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color(red: 0.1, green: 0.2, blue: 0.4) : Color.white)
                    .shadow(color: isSelected ? .black.opacity(0.2) : .black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color.clear : Color(red: 0.1, green: 0.2, blue: 0.4).opacity(0.2),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Donation Impact Summary
struct DonationImpactSummary: View {
    let totalDonations: Int
    let totalAmount: Double
    let impactDescription: String
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                // Total donations
                VStack(spacing: 4) {
                    Text("\(totalDonations)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
                    
                    Text("Donations")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Divider()
                    .frame(height: 40)
                
                // Total amount
                VStack(spacing: 4) {
                    Text("$\(String(format: "%.0f", totalAmount))")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
                    
                    Text("Raised")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            
            // Impact description
            Text(impactDescription)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
}

#Preview {
    WhyDonateSection()
        .padding()
        .background(Color.gray.opacity(0.1))
} 