import SwiftUI

// MARK: - History View
struct HistoryView: View {
    @StateObject private var viewModel = DonationFlowViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.donationHistory.isEmpty {
                    emptyStateView
                } else {
                    donationHistoryList
                }
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                // Refresh donation history
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Spacer()
            
            // Empty state icon
            ZStack {
                Circle()
                    .fill(DesignSystem.Colors.primary.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(DesignSystem.Colors.primary)
            }
            
            // Empty state text
            VStack(spacing: DesignSystem.Spacing.md) {
                Text("No Donations Yet")
                    .font(DesignSystem.Typography.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                
                Text("Your donation history will appear here once you make your first donation.")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignSystem.Spacing.xl)
            }
            
            // Call to action
            Button("Explore Charities") {
                // Navigate to explore
            }
            .primaryButtonStyle()
            .padding(.horizontal, DesignSystem.Spacing.xl)
            
            Spacer()
        }
    }
    
    // MARK: - Donation History List
    private var donationHistoryList: some View {
        ScrollView {
            LazyVStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(viewModel.donationHistory.sorted(by: { $0.timestamp > $1.timestamp })) { donation in
                    DonationHistoryRow(donation: donation)
                }
            }
            .padding(DesignSystem.Spacing.md)
        }
    }
}

// MARK: - Donation History Row
struct DonationHistoryRow: View {
    let donation: DonationModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            // Header with charity info and amount
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(donation.charityName)
                        .font(DesignSystem.Typography.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                    
                    if let impactDescription = donation.impactDescription {
                        Text(impactDescription)
                            .font(DesignSystem.Typography.caption1)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: DesignSystem.Spacing.xs) {
                    Text("$\(String(format: "%.2f", donation.amount))")
                        .font(DesignSystem.Typography.title3)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.Colors.primary)
                    
                    Text(donation.timestamp, style: .date)
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
            }
            
            // Footer with payment method and status
            HStack {
                // Payment method
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: donation.paymentMethod.iconName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                    
                    Text(donation.paymentMethod.displayName)
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
                
                Spacer()
                
                // Status indicator
                if donation.status == .completed {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(DesignSystem.Colors.success)
                        
                        Text("Completed")
                            .font(DesignSystem.Typography.caption1)
                            .fontWeight(.medium)
                            .foregroundColor(DesignSystem.Colors.success)
                    }
                }
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .fill(DesignSystem.Colors.cardBackground)
                .shadow(
                    color: DesignSystem.Shadows.small.color,
                    radius: DesignSystem.Shadows.small.radius,
                    x: DesignSystem.Shadows.small.x,
                    y: DesignSystem.Shadows.small.y
                )
        )
    }
}

// MARK: - Payment Method Extension
extension DonationModel.PaymentMethod {
    var displayName: String {
        switch self {
        case .applePay:
            return "Apple Pay"
        case .creditCard:
            return "Credit Card"
        case .bankTransfer:
            return "Bank Transfer"
        }
    }
    
    var iconName: String {
        switch self {
        case .applePay:
            return "applelogo"
        case .creditCard:
            return "creditcard"
        case .bankTransfer:
            return "building.columns"
        }
    }
}

// MARK: - Preview
#Preview {
    HistoryView()
}
