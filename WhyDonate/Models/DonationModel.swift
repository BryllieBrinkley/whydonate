import Foundation
import StoreKit
import PassKit

// Donation transaction model
struct DonationModel: Identifiable, Codable {
    var id = UUID()
    let charityId: String
    let charityName: String
    let amount: Double
    let currency: String
    let transactionId: String?
    let status: DonationStatus
    let timestamp: Date
    let impactDescription: String?
    let paymentMethod: PaymentMethod
    
    enum DonationStatus: String, Codable {
        case pending = "pending"
        case completed = "completed"
        case failed = "failed"
        case refunded = "refunded"
    }
    
    enum PaymentMethod: String, Codable {
        case applePay = "apple_pay"
        case creditCard = "credit_card"
        case bankTransfer = "bank_transfer"
    }
}

// Quick donate preset amounts
struct QuickDonateAmount: Identifiable {
    let id = UUID()
    let amount: Double
    let impactDescription: String
    let isPopular: Bool
    
    static let presetAmounts: [QuickDonateAmount] = [
        QuickDonateAmount(amount: 5.0, impactDescription: "$5 provides clean water for 1 person", isPopular: false),
        QuickDonateAmount(amount: 10.0, impactDescription: "$10 vaccinates 5 children", isPopular: true),
        QuickDonateAmount(amount: 25.0, impactDescription: "$25 feeds a family for 1 week", isPopular: false),
        QuickDonateAmount(amount: 50.0, impactDescription: "$50 provides emergency shelter", isPopular: false),
        QuickDonateAmount(amount: 100.0, impactDescription: "$100 funds medical treatment", isPopular: false)
    ]
}

// Impact statistics for "Why Donate?" sections
struct ImpactStat: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let description: String
    let icon: String
    
    static let impactStats: [ImpactStat] = [
        ImpactStat(title: "Children Vaccinated", value: "50,000+", description: "Through your donations", icon: "heart.fill"),
        ImpactStat(title: "Families Fed", value: "10,000+", description: "Meals provided monthly", icon: "house.fill"),
        ImpactStat(title: "Clean Water", value: "25,000+", description: "People with access", icon: "drop.fill"),
        ImpactStat(title: "Medical Care", value: "5,000+", description: "Patients treated", icon: "cross.fill")
    ]
}

// Apple Pay configuration
struct ApplePayConfig {
    static let merchantIdentifier = "merchant.com.whydonate.app"
    static let supportedNetworks: [PKPaymentNetwork] = [.visa, .masterCard, .amex]
    static let merchantCapabilities: PKMerchantCapability = [.capability3DS, .capabilityEMV]
    
    static func createPaymentRequest(for amount: Double, charity: CharityModel) -> PKPaymentRequest {
        let request = PKPaymentRequest()
        request.merchantIdentifier = merchantIdentifier
        request.supportedNetworks = supportedNetworks
        request.merchantCapabilities = merchantCapabilities
        request.countryCode = "US"
        request.currencyCode = "USD"
        
        let paymentItem = PKPaymentSummaryItem(label: charity.name, amount: NSDecimalNumber(value: amount))
        let totalItem = PKPaymentSummaryItem(label: "WhyDonate", amount: NSDecimalNumber(value: amount))
        
        request.paymentSummaryItems = [paymentItem, totalItem]
        return request
    }
}

// Transaction fee calculation
struct TransactionFee {
    static let percentage: Double = 0.015 // 1.5% transaction fee
    
    static func calculateFee(for amount: Double) -> Double {
        return amount * percentage
    }
    
    static func calculateTotalWithFee(for amount: Double) -> Double {
        return amount + calculateFee(for: amount)
    }
}

// Analytics and metrics tracking
struct DonationMetrics: Codable {
    let totalDonations: Int
    let totalAmount: Double
    let averageDonation: Double
    let topCharities: [String]
    let monthlyGrowth: Double
    
    static func calculateMetrics(from donations: [DonationModel]) -> DonationMetrics {
        let totalDonations = donations.count
        let totalAmount = donations.reduce(0) { $0 + $1.amount }
        let averageDonation = totalDonations > 0 ? totalAmount / Double(totalDonations) : 0
        
        // Calculate top charities
        let charityCounts = Dictionary(grouping: donations, by: { $0.charityName })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
            .prefix(5)
            .map { $0.key }
        
        return DonationMetrics(
            totalDonations: totalDonations,
            totalAmount: totalAmount,
            averageDonation: averageDonation,
            topCharities: Array(charityCounts),
            monthlyGrowth: 0 // Calculate based on monthly data
        )
    }
} 
