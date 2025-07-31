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
                VStack(spacing: 24) {
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
                .padding()
            }
            .navigationTitle("Donate")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
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
        VStack(spacing: 16) {
            // Charity logo
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
                .frame(width: 80, height: 80)
                .overlay(
                    Text(String(charity.name.prefix(2)).uppercased())
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                )
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            VStack(spacing: 8) {
                Text(charity.name)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
                    .multilineTextAlignment(.center)
                
                if let category = charity.category {
                    Text(category)
                        .font(.system(size: 16, weight: .medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(red: 0.0, green: 0.3, blue: 0.4).opacity(0.1))
                        )
                        .foregroundColor(Color(red: 0.0, green: 0.3, blue: 0.4))
                }
                
                if let rating = charity.rating {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", rating))
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
            }
        }
    }
    
    // MARK: - Quick Donate Section
    private var quickDonateSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Donate")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
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
        VStack(alignment: .leading, spacing: 12) {
            Text("Custom Amount")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
            
            HStack {
                Text("$")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.secondary)
                
                TextField("0.00", text: $customAmount)
                    .font(.system(size: 20, weight: .medium))
                    .keyboardType(.decimalPad)
                    .onChange(of: customAmount) { newValue in
                        if let amount = Double(newValue), amount > 0 {
                            selectedAmount = amount
                        }
                    }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            )
        }
    }
    
    // MARK: - Impact Section
    private var impactSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Impact")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
            
            VStack(spacing: 8) {
                ForEach(QuickDonateAmount.presetAmounts) { preset in
                    if selectedAmount == preset.amount {
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                                .font(.system(size: 16, weight: .medium))
                            
                            Text(preset.impactDescription)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Spacer()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.red.opacity(0.1))
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Donate Button
    private var donateButton: some View {
        VStack(spacing: 12) {
            Button(action: {
                Task {
                    await processDonation()
                }
            }) {
                HStack(spacing: 8) {
                    if storeKitManager.isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 18, weight: .medium))
                    }
                    Text(storeKitManager.isLoading ? "Processing..." : "Donate Now")
                        .font(.system(size: 18, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.1, green: 0.2, blue: 0.4))
                )
            }
            .disabled(selectedAmount <= 0 || storeKitManager.isLoading)
            
            Text("Secure payment through App Store")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
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
            VStack(spacing: 8) {
                HStack {
                    Text("$\(String(format: "%.0f", amount))")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(isSelected ? .white : Color(red: 0.1, green: 0.2, blue: 0.4))
                    
                    Spacer()
                    
                    if isPopular {
                        Text("POPULAR")
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }
                }
                
                Text(impactDescription)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color(red: 0.1, green: 0.2, blue: 0.4) : Color.white)
                    .shadow(color: isSelected ? .black.opacity(0.1) : .black.opacity(0.05), radius: 2, x: 0, y: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.clear : Color(red: 0.1, green: 0.2, blue: 0.4).opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    DonationFlowView(charity: CharityModel(
        name: "St. Jude Children's Research Hospital",
        description: "Leading pediatric treatment and research facility",
        imageName: "st-jude",
        ein: "62-0646012",
        mission: "To advance cures, and means of prevention, for pediatric catastrophic diseases through research and treatment.",
        category: "Healthcare",
        location: CharityLocation(city: "Memphis", state: "TN", country: "USA", zipCode: "38105"),
        website: "https://www.stjude.org",
        rating: 4.9,
        verified: true
    ))
} 
