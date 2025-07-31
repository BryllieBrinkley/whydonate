import Foundation
import StoreKit
import Combine
import os.log

// MARK: - Store Error Types
enum StoreError: LocalizedError {
    case failedVerification
    case productNotFound
    case purchaseCancelled
    case networkError
    case serverError
    
    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Transaction verification failed"
        case .productNotFound:
            return "Product not found"
        case .purchaseCancelled:
            return "Purchase was cancelled"
        case .networkError:
            return "Network connection error"
        case .serverError:
            return "Server error occurred"
        }
    }
}

// MARK: - StoreKit Manager
@MainActor
final class StoreKitManager: NSObject, ObservableObject {
    static let shared = StoreKitManager()
    
    // MARK: - Published Properties
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProducts: Set<String> = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    
    // MARK: - Private Properties
    private let logger = Logger(subsystem: "com.whydonate.store", category: "StoreKit")
    private let productIDs = [
        "com.whydonate.donation.5",
        "com.whydonate.donation.10", 
        "com.whydonate.donation.25",
        "com.whydonate.donation.50",
        "com.whydonate.donation.100"
    ]
    private var updateListenerTask: Task<Void, Error>?
    
    // MARK: - Initialization
    override init() {
        super.init()
        setupTransactionListener()
        Task {
            await loadProducts()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Public Methods
    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            products = try await Product.products(for: productIDs)
            logger.info("Successfully loaded \(self.products.count) products")
            isLoading = false
        } catch {
            logger.error("Failed to load products: \(error.localizedDescription)")
            errorMessage = "Failed to load products: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func purchase(_ product: Product) async throws -> Transaction? {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await updatePurchasedProducts()
                logger.info("Purchase successful for product: \(product.id)")
                return transaction
                
            case .userCancelled:
                logger.info("Purchase cancelled by user")
                return nil
                
            case .pending:
                errorMessage = "Purchase is pending approval"
                logger.warning("Purchase pending approval")
                return nil
                
            @unknown default:
                errorMessage = "Unknown purchase result"
                logger.error("Unknown purchase result")
                return nil
            }
        } catch {
            logger.error("Purchase failed: \(error.localizedDescription)")
            errorMessage = "Purchase failed: \(error.localizedDescription)"
            throw error
        }
    }
    
    func purchaseDonation(amount: Double, charity: CharityModel) async throws -> DonationModel {
        guard let product = getProduct(for: amount) else {
            logger.error("Product not found for amount: \(amount)")
            throw StoreError.productNotFound
        }
        
        guard let transaction = try await purchase(product) else {
            throw StoreError.purchaseCancelled
        }
        
        let donation = DonationModel(
            charityId: charity.id.uuidString,
            charityName: charity.name,
            amount: amount,
            currency: "USD",
            transactionId: transaction.id.description,
            status: .completed,
            timestamp: Date(),
            impactDescription: getImpactDescription(for: amount),
            paymentMethod: .applePay
        )
        
        logger.info("Donation processed: \(charity.name) - $\(amount)")
        return donation
    }
    
    func restorePurchases() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
            logger.info("Purchases restored successfully")
            isLoading = false
        } catch {
            logger.error("Failed to restore purchases: \(error.localizedDescription)")
            errorMessage = "Failed to restore purchases: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func isPurchased(_ productID: String) -> Bool {
        return purchasedProducts.contains(productID)
    }
    
    func getProduct(for amount: Double) -> Product? {
        let productID = "com.whydonate.donation.\(Int(amount))"
        return self.products.first { $0.id == productID }
    }
    
    // MARK: - Private Methods
    private func setupTransactionListener() {
        updateListenerTask = Task.detached { [weak self] in
            guard let self = self else { return }
            
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)
                    await self.updatePurchasedProducts()
                    await transaction.finish()
                } catch {
                    self.logger.error("Transaction failed verification: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    private func updatePurchasedProducts() async {
        var purchasedProductIDs: Set<String> = []
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                purchasedProductIDs.insert(transaction.productID)
            } catch {
                logger.error("Transaction failed verification during update: \(error.localizedDescription)")
            }
        }
        
        purchasedProducts = purchasedProductIDs
    }
    
    private func getImpactDescription(for amount: Double) -> String {
        switch amount {
        case 5:
            return "$5 provides clean water for 1 person"
        case 10:
            return "$10 vaccinates 5 children"
        case 25:
            return "$25 feeds a family for 1 week"
        case 50:
            return "$50 provides emergency shelter"
        case 100:
            return "$100 funds medical treatment"
        default:
            return "$\(Int(amount)) makes a difference"
        }
    }
} 
