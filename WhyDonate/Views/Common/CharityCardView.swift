import SwiftUI

struct CharityCardView: View {
    let charity: CharityModel
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with image and urgency indicator
            headerSection
            
            // Content section
            contentSection
        }
        .background(cardBackground)
        .overlay(cardBorder)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(DesignSystem.Animation.quick, value: isPressed)
        .onTapGesture {
            handleTap()
        }
        // Performance optimization: Stable identity for SwiftUI
        .id(charity.id)
        // Accessibility improvements
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(charity.name). \(charity.description)")
        .accessibilityHint(charity.isUrgent ? "Urgent charity" : "Tap to learn more")
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        ZStack(alignment: .topTrailing) {
            // Charity image/icon background
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .fill(DesignSystem.Colors.primaryGradient)
                .frame(height: 120)
                .overlay(
                    Image(systemName: charity.imageName)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.white)
                )
            
            // Urgency badge
            if charity.isUrgent {
                urgencyBadge
            }
        }
    }
    
    // MARK: - Urgency Badge
    private var urgencyBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 10, weight: .bold))
            Text("URGENT")
                .font(DesignSystem.Typography.caption2)
                .fontWeight(.bold)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(DesignSystem.Colors.warning)
        )
        .padding(DesignSystem.Spacing.sm)
    }
    
    // MARK: - Content Section
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            // Charity name and category
            charityInfoSection
            
            // Description
            Text(charity.description)
                .font(DesignSystem.Typography.cardBody)
                .foregroundColor(DesignSystem.Colors.secondaryText)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            // Location indicator
            if charity.location != nil {
                locationIndicator
            }
            
            // Progress indicator
            if let donationGoal = charity.donationGoal {
                progressSection(donationGoal: donationGoal)
            }
        }
        .padding(DesignSystem.Spacing.md)
    }
    
    // MARK: - Charity Info Section
    private var charityInfoSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(charity.name)
                .font(DesignSystem.Typography.cardTitle)
                .fontWeight(.semibold)
                .foregroundColor(DesignSystem.Colors.primaryText)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            Text(charity.category)
                .font(DesignSystem.Typography.caption1)
                .foregroundColor(DesignSystem.Colors.secondaryText)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(
                    Capsule()
                        .fill(DesignSystem.Colors.primary.opacity(0.1))
                )
        }
    }
    
    // MARK: - Location Indicator
    private var locationIndicator: some View {
        HStack(spacing: 4) {
            Image(systemName: "location.fill")
                .font(.system(size: 10))
                .foregroundColor(DesignSystem.Colors.primary)
            Text("Local")
                .font(DesignSystem.Typography.caption2)
                .foregroundColor(DesignSystem.Colors.primary)
                .fontWeight(.medium)
        }
    }
    
    // MARK: - Progress Section
    private func progressSection(donationGoal: Double) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Progress")
                    .font(DesignSystem.Typography.caption2)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                Spacer()
                Text("\(Int(charity.progress * 100))%")
                    .font(DesignSystem.Typography.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.Colors.primary)
            }
            
            // Progress bar
            progressBar
            
            // Amount raised
            HStack {
                Text("$\(formatAmount(charity.amountRaised ?? 0)) raised")
                    .font(DesignSystem.Typography.caption2)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                Spacer()
                Text("of $\(formatAmount(donationGoal))")
                    .font(DesignSystem.Typography.caption2)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
        }
    }
    
    // MARK: - Progress Bar
    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(DesignSystem.Colors.secondaryBackground)
                    .frame(height: 4)
                
                RoundedRectangle(cornerRadius: 2)
                    .fill(DesignSystem.Colors.primaryGradient)
                    .frame(width: geometry.size.width * charity.progress, height: 4)
                    .animation(DesignSystem.Animation.standard, value: charity.progress)
            }
        }
        .frame(height: 4)
    }
    
    // MARK: - Card Background
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
            .fill(DesignSystem.Colors.cardBackground)
            .shadow(
                color: DesignSystem.Shadows.medium.color,
                radius: DesignSystem.Shadows.medium.radius,
                x: DesignSystem.Shadows.medium.x,
                y: DesignSystem.Shadows.medium.y
            )
    }
    
    // MARK: - Card Border
    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
            .stroke(DesignSystem.Colors.cardBorder, lineWidth: 0.5)
    }
    
    // MARK: - Tap Handler
    private func handleTap() {
        withAnimation(DesignSystem.Animation.quick) {
            isPressed = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(DesignSystem.Animation.quick) {
                isPressed = false
            }
        }
    }
    
    // MARK: - Helper Methods
    private func formatAmount(_ amount: Double) -> String {
        if amount >= 1_000_000 {
            return String(format: "%.1fM", amount / 1_000_000)
        } else if amount >= 1_000 {
            return String(format: "%.1fK", amount / 1_000)
        } else {
            return String(format: "%.0f", amount)
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: DesignSystem.Spacing.lg) {
        CharityCardView(
            charity: CharityModel(
                name: "St. Jude Children's Hospital",
                description: "Leading the way the world understands, treats and defeats childhood cancer.",
                imageName: "heart.fill",
                category: "Health",
                verified: true,
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
                verified: true,
                donationGoal: 500000,
                amountRaised: 200000,
                location: "Local Community"
            )
        )
    }
    .padding()
}
