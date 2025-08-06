import SwiftUI
import StoreKit
import PassKit

struct DonationFlowView: View {
    let charity: CharityModel
    @StateObject private var viewModel = DonationFlowViewModel()
    @StateObject private var storeKitManager = StoreKitManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedAmount: Double = 10.0
    @State private var customAmount: String = ""
    @State private var showingSuccess = false
    @State private var showingError = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.sectionSpacing) {
                    // Charity header
                    charityHeader
                    
                    // Quick donate amounts
                    quickDonateSection
                    
                    // Custom amount
                    customAmountSection
                    
                    // Impact description
                    impactSection
                    
                    // Donate button
                    donateButton
                }
                .padding(DesignSystem.Spacing.md)
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle("Donate")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(DesignSystem.Colors.primary)
                }
            }
        }
        .alert("Donation Successful!", isPresented: $showingSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Thank you for your donation to \(charity.name)!")
        }
        .alert("Donation Failed", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(storeKitManager.errorMessage ?? "An error occurred during donation")
        }
        .onAppear {
            Task {
                await storeKitManager.loadProducts()
            }
        }
    }
    
    // MARK: - Charity Header
    private var charityHeader: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Charity logo
            ZStack {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                    .fill(DesignSystem.Colors.primaryGradient)
                    .frame(width: 100, height: 100)
                    .shadow(
                        color: DesignSystem.Shadows.medium.color,
                        radius: DesignSystem.Shadows.medium.radius,
                        x: DesignSystem.Shadows.medium.x,
                        y: DesignSystem.Shadows.medium.y
                    )
                
                Text(String(charity.name.prefix(2)).uppercased())
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text(charity.name)
                    .font(DesignSystem.Typography.title2)
                    .fontWeight(.bold)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                    .multilineTextAlignment(.center)
                
                Text(charity.category)
                    .font(DesignSystem.Typography.subheadline)
                    .fontWeight(.medium)
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.vertical, DesignSystem.Spacing.xs)
                    .background(
                        Capsule()
                            .fill(DesignSystem.Colors.primary.opacity(0.1))
                    )
                    .foregroundColor(DesignSystem.Colors.primary)
                
                if let rating = charity.rating {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Image(systemName: "star.fill")
                            .foregroundColor(DesignSystem.Colors.warning)
                        Text(String(format: "%.1f", rating))
                            .font(DesignSystem.Typography.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(DesignSystem.Colors.primaryText)
                    }
                }
            }
        }
    }
    
    // MARK: - Quick Donate Section
    private var quickDonateSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Quick Donate")
                .font(DesignSystem.Typography.headline)
                .fontWeight(.semibold)
                .foregroundColor(DesignSystem.Colors.primaryText)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: DesignSystem.Spacing.sm) {
                ForEach(QuickDonateAmount.presetAmounts) { preset in
                    QuickDonateButton(
                        amount: preset.amount,
                        impactDescription: preset.impactDescription,
                        isPopular: preset.isPopular,
                        isSelected: selectedAmount == preset.amount
                    ) {
                        selectedAmount = preset.amount
                        customAmount = ""
                    }
                }
            }
        }
    }
    
    // MARK: - Custom Amount Section
    private var customAmountSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Custom Amount")
                .font(DesignSystem.Typography.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(DesignSystem.Colors.primaryText)
            
            HStack(spacing: DesignSystem.Spacing.sm) {
                Text("$")
                    .font(DesignSystem.Typography.title3)
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                
                TextField("0.00", text: $customAmount)
                    .font(DesignSystem.Typography.title3)
                    .fontWeight(.medium)
                    .keyboardType(.decimalPad)
                    .onChange(of: customAmount) { newValue in
                        if let amount = Double(newValue), amount > 0 {
                            selectedAmount = amount
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
    
    // MARK: - Impact Section
    private var impactSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Your Impact")
                .font(DesignSystem.Typography.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(DesignSystem.Colors.primaryText)
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(QuickDonateAmount.presetAmounts) { preset in
                    if selectedAmount == preset.amount {
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            Image(systemName: "heart.fill")
                                .foregroundColor(DesignSystem.Colors.secondary)
                                .font(.system(size: 16, weight: .medium))
                            
                            Text(preset.impactDescription)
                                .font(DesignSystem.Typography.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(DesignSystem.Colors.primaryText)
                            
                            Spacer()
                        }
                        .padding(DesignSystem.Spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                                .fill(DesignSystem.Colors.secondary.opacity(0.1))
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Donate Button
    private var donateButton: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Button(action: {
                Task {
                    await processDonation()
                }
            }) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    if storeKitManager.isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 18, weight: .medium))
                    }
                    Text(storeKitManager.isLoading ? "Processing..." : "Donate Now")
                        .font(DesignSystem.Typography.buttonText)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.buttonPadding)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .fill(DesignSystem.Colors.primary)
                )
            }
            .disabled(selectedAmount <= 0 || storeKitManager.isLoading)
            
            Text("Secure payment through App Store")
                .font(DesignSystem.Typography.caption1)
                .foregroundColor(DesignSystem.Colors.secondaryText)
        }
    }
    
    // MARK: - Process Donation
    private func processDonation() async {
        do {
            let donation = try await storeKitManager.purchaseDonation(amount: selectedAmount, charity: charity)
            
            // Add to donation history
            try await viewModel.processDonation(charity: charity, amount: selectedAmount, paymentMethod: .applePay)
            
            showingSuccess = true
        } catch {
            showingError = true
        }
    }
}

// MARK: - Quick Donate Button
struct QuickDonateButton: View {
    let amount: Double
    let impactDescription: String
    let isPopular: Bool
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                HStack {
                    Text("$\(String(format: "%.0f", amount))")
                        .font(DesignSystem.Typography.title3)
                        .fontWeight(.bold)
                        .foregroundColor(isSelected ? .white : DesignSystem.Colors.primaryText)
                    
                    Spacer()
                    
                    if isPopular {
                        Text("POPULAR")
                            .font(DesignSystem.Typography.caption2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(DesignSystem.Colors.secondary)
                            .foregroundColor(.white)
                            .cornerRadius(DesignSystem.CornerRadius.xs)
                    }
                }
                
                Text(impactDescription)
                    .font(DesignSystem.Typography.caption1)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : DesignSystem.Colors.secondaryText)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
            }
            .padding(DesignSystem.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .fill(isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.cardBackground)
                    .shadow(
                        color: isSelected ? DesignSystem.Shadows.medium.color : DesignSystem.Shadows.small.color,
                        radius: isSelected ? DesignSystem.Shadows.medium.radius : DesignSystem.Shadows.small.radius,
                        x: isSelected ? DesignSystem.Shadows.medium.x : DesignSystem.Shadows.small.x,
                        y: isSelected ? DesignSystem.Shadows.medium.y : DesignSystem.Shadows.small.y
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .stroke(isSelected ? Color.clear : DesignSystem.Colors.primary.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    DonationFlowView(charity: CharityModel(
        name: "St. Jude Children's Research Hospital",
        description: "Leading pediatric treatment and research facility",
        imageName: "st-jude",
        category: "Healthcare",
        isUrgent: true,
        verified: true,
        donationGoal: 800000,
        amountRaised: 650000,
        location: "Memphis, TN",
        website: "https://www.stjude.org"
    ))
} 
