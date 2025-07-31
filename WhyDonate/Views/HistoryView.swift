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
            .navigationTitle("History")
            .refreshable {
                // Refresh donation history
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "heart.circle")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                Text("No Donations Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Your donation history will appear here once you make your first donation.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Donation History List
    private var donationHistoryList: some View {
        List {
            ForEach(viewModel.donationHistory.sorted(by: { $0.timestamp > $1.timestamp })) { donation in
                DonationHistoryRow(donation: donation)
            }
        }
        .listStyle(.plain)
    }
}

// MARK: - Donation History Row
struct DonationHistoryRow: View {
    let donation: DonationModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(donation.charityName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(donation.impactDescription ?? "")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("$\(String(format: "%.2f", donation.amount))")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
                    
                    Text(donation.timestamp, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                Label(donation.paymentMethod.displayName, systemImage: donation.paymentMethod.iconName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if donation.status == .completed {
                    Label("Completed", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
        }
        .padding(.vertical, 8)
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

#Preview {
    HistoryView()
}
