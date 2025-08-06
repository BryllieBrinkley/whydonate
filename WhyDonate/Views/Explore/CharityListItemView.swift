import SwiftUI

struct CharityListItemView: View {
    let charity: CharityModel
    @State private var isPressed = false
    @State private var showingDonationFlow = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                // Enhanced charity logo/placeholder
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.1, green: 0.2, blue: 0.4),
                                Color(red: 0.0, green: 0.3, blue: 0.4)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 70, height: 70)
                    .overlay(
                        Text(String(charity.name.prefix(2)).uppercased())
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                VStack(alignment: .leading, spacing: 12) {
                    // Enhanced charity name and verification badge
                    HStack(alignment: .top, spacing: 8) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(charity.name)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
                                .lineLimit(2)
                            
                            Text(charity.category)
                                .font(.system(size: 12, weight: .medium))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color(red: 0.0, green: 0.3, blue: 0.4).opacity(0.1))
                                )
                                .foregroundColor(Color(red: 0.0, green: 0.3, blue: 0.4))
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            // Verification badge
                            if charity.verified {
                                VStack(spacing: 2) {
                                    Image(systemName: "checkmark.seal.fill")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.green)
                                    Text("Verified")
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(.green)
                                }
                            }
                            
                            // Rating if available
                            if let rating = charity.rating {
                                VStack(spacing: 2) {
                                    HStack(spacing: 2) {
                                        Image(systemName: "star.fill")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.yellow)
                                        Text(String(format: "%.1f", rating))
                                            .font(.system(size: 12, weight: .bold))
                                    }
                                    Text("Rating")
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    
                    // Mission or description with better typography
                    if let mission = charity.mission {
                        Text(mission)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.secondary)
                            .lineLimit(3)
                            .multilineTextAlignment(.leading)
                    } else {
                        Text(charity.description)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.secondary)
                            .lineLimit(3)
                            .multilineTextAlignment(.leading)
                    }
                    
                    // Location and EIN info
                    HStack(spacing: 12) {
                        if let location = charity.location {
                            HStack(spacing: 4) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                                Text(location)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if let ein = charity.ein {
                            HStack(spacing: 4) {
                                Image(systemName: "doc.text.fill")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                                Text("EIN: \(ein)")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            
            // Enhanced action buttons
            HStack(spacing: 12) {
                // Donate button - Primary action
                Button(action: {
                    showingDonationFlow = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 14, weight: .medium))
                        Text("Donate Now")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(red: 0.1, green: 0.2, blue: 0.4))
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isPressed)
                .onTapGesture {
                    isPressed = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isPressed = false
                    }
                }
                
                if let website = charity.website {
                    Link(destination: URL(string: website)!) {
                        HStack(spacing: 6) {
                            Image(systemName: "globe")
                                .font(.system(size: 14, weight: .medium))
                            Text("Visit Website")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(red: 0.1, green: 0.2, blue: 0.4).opacity(0.1))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Spacer()
                
                // Learn more button
                Button(action: {
                    // TODO: Show charity detail view
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 14, weight: .medium))
                        Text("Learn More")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(red: 0.1, green: 0.2, blue: 0.4), lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(red: 0.1, green: 0.2, blue: 0.4).opacity(0.1), lineWidth: 1)
        )
        .sheet(isPresented: $showingDonationFlow) {
            DonationFlowView(charity: charity)
        }
    }
}

#Preview {
    CharityListItemView(charity: CharityModel(
        name: "American Red Cross",
        description: "Humanitarian organization providing emergency assistance, disaster relief, and education",
        imageName: "red-cross",
        category: "Disaster Relief",
        isUrgent: true,
        verified: true,
        donationGoal: 500000,
        amountRaised: 350000,
        location: "Washington, DC",
        website: "https://www.redcross.org"
    ))
    .padding()
    .background(Color.gray.opacity(0.1))
} 