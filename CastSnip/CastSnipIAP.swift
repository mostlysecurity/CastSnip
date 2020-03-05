//
//  CastSnipPayment.swift
//  CastSnip
//
//  Created by ewuehler on 3/2/19.
//  Copyright © 2019 Eric Wuehler. All rights reserved.
//
// Derived from: https://www.raywenderlich.com/5456-in-app-purchase-tutorial-getting-started

import StoreKit

public typealias ProductIdentifier = String
public typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> Void

extension Notification.Name {
    static let CastSnipPaymentPurchaseNotification = Notification.Name("CastSnipPaymentPurchaseNotification")
    static let CastSnipFailedPurchaseNotification =
        Notification.Name("CastSnipFailedPurchaseNotification")
    static let CastSnipFailedRestoreNotification =
        Notification.Name("CastSnipFailedRestoreNotification")
}


open class CastSnipIAP: NSObject {
    
    private let productIdentifiers: Set<ProductIdentifier>
    private var purchasedProductIdentifiers: Set<ProductIdentifier> = []
    private var productsRequest: SKProductsRequest?
    private var productsRequestCompletionHandler: ProductsRequestCompletionHandler?
    
    public init(productIds: Set<ProductIdentifier>) {
        productIdentifiers = productIds
        for productIdentifier in productIds {
            let purchased = UserDefaults.standard.bool(forKey: productIdentifier)
            if purchased {
                purchasedProductIdentifiers.insert(productIdentifier)
                print("Previously purchased: \(productIdentifier)")
            } else {
                print("Not purchased: \(productIdentifier)")
            }
        }
        super.init()
        
        SKPaymentQueue.default().add(self)
    }
    
}

// MARK: - StoreKit API

extension CastSnipIAP {
    
    public func requestProducts(_ completionHandler: @escaping ProductsRequestCompletionHandler) {
        productsRequest?.cancel()
        productsRequestCompletionHandler = completionHandler
        
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest!.delegate = self
        productsRequest!.start()
    }
    
    public func buyProduct(_ product: SKProduct) {
        print("Buying \(product.productIdentifier)...")
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    public func isProductPurchased(_ productIdentifier: ProductIdentifier) -> Bool {
        return purchasedProductIdentifiers.contains(productIdentifier)
    }
    
    public class func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    public func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

// MARK: - SKProductsRequestDelegate

extension CastSnipIAP: SKProductsRequestDelegate {
    
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Loaded list of products...")
        let products = response.products
        productsRequestCompletionHandler?(true, products)
        clearRequestAndHandler()
        
        for p in products {
            print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
        }
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Failed to load list of products.")
        print("Error: \(error.localizedDescription)")
        productsRequestCompletionHandler?(false, nil)
        clearRequestAndHandler()
    }
    
    private func clearRequestAndHandler() {
        productsRequest = nil
        productsRequestCompletionHandler = nil
    }
}

// MARK: - SKPaymentTransactionObserver

extension CastSnipIAP: SKPaymentTransactionObserver {
    
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        
//        print("something happened here: \(queue)")
        if (queue.transactions.count == 0) {
            deliverFailedPurchaseNotificationFor(identifier: nil, type: "restore", error: nil)
        } else {
        }

    }
    
    public func paymentQueue(_ queue: SKPaymentQueue,
                      restoreCompletedTransactionsFailedWithError error: Error) {
//        print("something here: \(queue); \(error)")
        deliverFailedPurchaseNotificationFor(identifier: nil, type:"restore", error: error)
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        print("started to purchase: \(product)")
        return true
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch (transaction.transactionState) {
            case .purchased:
                complete(transaction: transaction)
                break
            case .failed:
                fail(transaction: transaction)
                break
            case .restored:
                restore(transaction: transaction)
                break
            case .deferred:
                break
            case .purchasing:
                break
            @unknown default:
                break
            }
        }
    }
    
    private func complete(transaction: SKPaymentTransaction) {
        print("complete...")
        deliverPurchaseNotificationFor(identifier: transaction.payment.productIdentifier, date: transaction.transactionDate)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func restore(transaction: SKPaymentTransaction) {
        guard let productIdentifier = transaction.original?.payment.productIdentifier else {
            deliverFailedPurchaseNotificationFor(identifier: nil)
            return
        }
        
        print("restore... \(productIdentifier)")
        var date: Date? = transaction.transactionDate
        if (transaction.original != nil) {
            date = transaction.original!.transactionDate
        }
        deliverPurchaseNotificationFor(identifier: productIdentifier, date: date)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func fail(transaction: SKPaymentTransaction) {
        print("fail...")
        if let transactionError = transaction.error as NSError?,
            let localizedDescription = transaction.error?.localizedDescription,
            transactionError.code != SKError.paymentCancelled.rawValue {
            print("Transaction Error: \(localizedDescription)")
        }
        deliverFailedPurchaseNotificationFor(identifier: transaction.payment.productIdentifier)
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func deliverPurchaseNotificationFor(identifier: String?, date: Date?) {
        guard let identifier = identifier else { return }
        
        purchasedProductIdentifiers.insert(identifier)
        Select.setting.addSubscription(identifier, transaction: date)
        NotificationCenter.default.post(name: .CastSnipPaymentPurchaseNotification, object: identifier)
    }
    
    private func deliverFailedPurchaseNotificationFor(identifier: String?, type: String = "purchase", error: Error? = nil) {
        
        if (type == "restore") {
            NotificationCenter.default.post(name: .CastSnipFailedRestoreNotification, object: identifier ?? "NA")
        } else {
            NotificationCenter.default.post(name: .CastSnipFailedPurchaseNotification, object: identifier ?? "NA")
        }
    }
}

