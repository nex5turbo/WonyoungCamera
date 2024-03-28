//
//  WonyoungCameraApp.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2022/09/22.
//

import SwiftUI
import AVFoundation
import SwiftyStoreKit
import GoogleMobileAds
import FirebaseCore

@main
struct WonyoungCameraApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    @StateObject var ad = OpenAd()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(ad)
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active && !InAppPurchaseManager.shared.isPremiumUser {
                ad.requestAppOpenAd()
            } else {
                ad.didDismiss = true
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
        
    static var orientationLock = UIInterfaceOrientationMask.portrait //By default you want all your views to rotate freely

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        GADMobileAds.sharedInstance().start()
        FirebaseApp.configure()
        SwiftyStoreKit.completeTransactions(atomically: false) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    // Unlock content
                    InAppPurchaseManager.shared.setUserPremium(as: true)
                case .failed, .purchasing, .deferred:
                    break
                @unknown default:
                    break
                }
            }
        }
        return true
    }
}
