import Foundation
import Combine
import PassKit
import os.log

// MARK: - Donation Flow View Model
@MainActor
final class DonationFlowViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var donationHistory: [DonationModel] = []
    @Published private(set) var metrics: DonationMetrics?
    
    // MARK: - Private Properties
    private let logger = Logger(subsystem: "com.whydonate.donation", category: "DonationVM")
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        loadDonationHistory()
        calculateMetrics()
    }
    
    // MARK: - Public Methods
    func processDonation(charity: CharityModel, amount: Double, paymentMethod: DonationModel.PaymentMethod) async throws -> DonationModel {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        do {
            // Simulate payment processing
            try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            
            let donation = DonationModel(
                charityId: charity.id.uuidString,
                charityName: charity.name,
                amount: amount,
                currency: "USD",
                transactionId: generateTransactionId(),
                status: .completed,
                timestamp: Date(),
                impactDescription: getImpactDescription(for: amount),
                paymentMethod: paymentMethod
            )
            
            // Add to donation history
            donationHistory.append(donation)
            
            // Update metrics
            calculateMetrics()
            
            // Track analytics
            trackDonationAnalytics(donation)
            
            logger.info("Donation processed successfully: \(charity.name) - $\(amount)")
            return donation
            
        } catch {
            logger.error("Donation processing failed: \(error.localizedDescription)")
            errorMessage = "Payment processing failed. Please try again."
            throw error
        }
    }
    
    func getTransactionFee(for amount: Double) -> Double {
        return TransactionFee.calculateFee(for: amount)
    }
    
    func getTotalWithFee(for amount: Double) -> Double {
        return TransactionFee.calculateTotalWithFee(for: amount)
    }
    
    func validateAmount(_ amount: Double) -> Bool {
        return amount >= 1.0 && amount <= 10000.0
    }
    
    func getImpactStats() -> [ImpactStat] {
        return ImpactStat.impactStats
    }
    
    func getQuickDonateAmounts() -> [QuickDonateAmount] {
        return QuickDonateAmount.presetAmounts
    }
    
    func isApplePayAvailable() -> Bool {
        return PKPaymentAuthorizationViewController.canMakePayments()
    }
    
    func getDonationSuccessRate() -> Double {
        let completed = self.donationHistory.filter { $0.status == .completed }.count
        let total = self.donationHistory.count
        return total > 0 ? Double(completed) / Double(total) : 1.0
    }
    
    func getAverageDonationAmount() -> Double {
        let completed = self.donationHistory.filter { $0.status == .completed }
        let total = completed.reduce(0) { $0 + $1.amount }
        return completed.isEmpty ? 0 : total / Double(completed.count)
    }
    
    func getTopCharities() -> [String] {
        let charityCounts = Dictionary(grouping: donationHistory, by: { $0.charityName })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
            .prefix(5)
            .map { $0.key }
        
        return Array(charityCounts)
    }
    
    func getMonthlyDonationTrend() -> [Double] {
        // In a real app, this would calculate monthly trends
        // For now, return sample data
        return [1250.0, 1400.0, 1600.0, 1800.0, 2000.0, 2200.0]
    }
    
    func exportDonationData() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        var csv = "Date,Charity,Amount,Transaction ID\n"
        
        for donation in donationHistory where donation.status == .completed {
            let date = formatter.string(from: donation.timestamp)
            csv += "\(date),\(donation.charityName),$\(donation.amount),\(donation.transactionId ?? "")\n"
        }
        
        return csv
    }
    
    // MARK: - Private Methods
    private func loadDonationHistory() {
        // In a real app, this would load from Core Data or a backend
        // For now, we'll use sample data
        donationHistory = [
            DonationModel(
                charityId: "1",
                charityName: "St. Jude Children's Research Hospital",
                amount: 25.0,
                currency: "USD",
                transactionId: "TXN_001",
                status: .completed,
                timestamp: Date().addingTimeInterval(-86400), // 1 day ago
                impactDescription: "$25 feeds a family for 1 week",
                paymentMethod: .applePay
            ),
            DonationModel(
                charityId: "2",
                charityName: "American Red Cross",
                amount: 10.0,
                currency: "USD",
                transactionId: "TXN_002",
                status: .completed,
                timestamp: Date().addingTimeInterval(-172800), // 2 days ago
                impactDescription: "$10 vaccinates 5 children",
                paymentMethod: .applePay
            )
        ]
    }
    
    private func calculateMetrics() {
        metrics = DonationMetrics.calculateMetrics(from: donationHistory)
    }
    
    private func trackDonationAnalytics(_ donation: DonationModel) {
        // In a real app, this would send analytics to Firebase, Mixpanel, etc.
        logger.info("Donation tracked: \(donation.charityName) - $\(donation.amount)")
    }
    
    private func generateTransactionId() -> String {
        let timestamp = Int(Date().timeIntervalSince1970)
        let random = Int.random(in: 1000...9999)
        return "TXN_\(timestamp)_\(random)"
    }
    
    private func getImpactDescription(for amount: Double) -> String {
        switch amount {
        case 0..<10:
            return "$\(Int(amount)) provides clean water for \(Int(amount/5)) people"
        case 10..<25:
            return "$\(Int(amount)) vaccinates \(Int(amount/2)) children"
        case 25..<50:
            return "$\(Int(amount)) feeds a family for \(Int(amount/25)) weeks"
        case 50..<100:
            return "$\(Int(amount)) provides emergency shelter"
        default:
            return "$\(Int(amount)) funds comprehensive medical treatment"
        }
    }
} 