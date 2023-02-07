//
//  PurchaseManager.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2023/02/07.
//

import Foundation
import SwiftyStoreKit
import StoreKit

class InAppPurchaseManager: ObservableObject {
    static let shared = InAppPurchaseManager()
    @Published var isPremiumUser: Bool = false
    @Published var subscriptionViewPresent: Bool = false
    private var products: Set<SKProduct> = []
    let productId = "PERMANENT"

    init() {
        self.isPremiumUser = UserDefaults.standard.bool(forKey: "isPremium")

        SwiftyStoreKit.retrieveProductsInfo([productId]) { result in
            self.products = result.retrievedProducts
        }
    }
    func purchase(completion: @escaping (Result<PurchaseDetails, SKError>) -> Void) {
        SwiftyStoreKit.purchaseProduct(productId, quantity: 1, atomically: true) { result in
            switch result {
            case .success(purchase: let purchase):
                completion(.success(purchase))
            case .deferred(purchase: let purchase):
                completion(.success(purchase))
            case .error(error: let error):
                completion(.failure(error))
            }
        }
    }

    func restore(completion: @escaping (Bool, String) -> Void) {
        SwiftyStoreKit.restorePurchases(atomically: true) { result in
            if let error = result.restoreFailedPurchases.first?.1 {
                completion(false, error)
                return
            }
            if let success = result.restoredPurchases.first {
                if success.needsFinishTransaction {
                    completion(false, "Please try again.")
                    return
                }
                self.setUserPremium(as: true)
                completion(true, "Restored.")
                return
            }
        }
    }
    
    func setUserPremium(as value: Bool) {
        self.isPremiumUser = value
        UserDefaults.standard.set(value, forKey: "isPremium")
    }
    func getPermanentPrice() -> String? {
        for product in self.products where product.productIdentifier == productId {
            return product.localizedPrice
        }
        return nil
    }
}
