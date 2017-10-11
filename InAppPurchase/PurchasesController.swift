import Foundation
import StoreKit

protocol PurchasesControllerProtocol {
    var canMakePayments: Bool { get }
    
    func buyItem(withProductID productID: String)
    func restorePurchases()
    
    var onPurchase: ((String) -> ())? { get set }
    var onRestore: ((String) -> ())? { get set }
    var onFail: ((String) -> ())? { get set }
    var onCancel: (() -> ())? { get set }
}

class PurchasesController: NSObject, PurchasesControllerProtocol {
    
    public var canMakePayments: Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    public var onPurchase: ((String) -> ())?
    public var onRestore: ((String) -> ())?
    public var onFail: ((String) -> ())?
    public var onCancel: (() -> ())?
    
    private var productRequest: SKProductsRequest?
    private let productIdentifiers: [String]
    fileprivate var products: [SKProduct]?
    
    init(withProductIDs productIDs: [String]) {
        self.productIdentifiers = productIDs
        
        super.init()
        
        self.validateProductIdentifiers(productIdentifiers)
        
        SKPaymentQueue.default().add(self)
    }
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    
    // MARK: - Validation
    private func validateProductIdentifiers(_ identifiers: [String]) {
        self.productRequest = SKProductsRequest(productIdentifiers: Set(identifiers))
        self.productRequest?.delegate = self
        self.productRequest?.start()
    }
    
    // MARK: - Payment
    public func buyItem(withProductID productID: String) {
        guard let product = products?.filter({ return $0.productIdentifier == productID }).first else {
            return
        }
        buy(product)
    }
    
    private func buy(_ product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    public func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

// MARK: - SKProductsRequestDelegate
extension PurchasesController: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
    }
}

// MARK: - SKPaymentTransactionObserver
extension PurchasesController: SKPaymentTransactionObserver {
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch (transaction.transactionState) {
            case .purchased:
                processPurchased(transaction: transaction)
            case .failed:
                processFailed(transaction: transaction)
            case .restored:
                processRestored(transaction: transaction)
            case .deferred, .purchasing:
                break
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        onCancel?()
    }
    
    private func processPurchased(transaction: SKPaymentTransaction) {
        savePurchase(identifier: transaction.payment.productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
        
        onPurchase?(transaction.payment.productIdentifier)
    }
    
    private func processRestored(transaction: SKPaymentTransaction) {
        guard let productIdentifier = transaction.original?.payment.productIdentifier else {
            return
        }
        savePurchase(identifier: productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
        
        onRestore?(productIdentifier)
    }
    
    private func processFailed(transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
        
        onFail?(transaction.payment.productIdentifier)
    }
    
    private func savePurchase(identifier: String?) {
        guard let identifier = identifier else {
            return
        }
        UserDefaults.standard.set(true, forKey: identifier)
        UserDefaults.standard.synchronize()
    }
}
