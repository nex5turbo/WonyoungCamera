//
//  InterstitialAd.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2023/07/16.
//

import GoogleMobileAds
import Foundation

extension UIApplication {
    
    var keyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })?.windows
            .first(where: \.isKeyWindow)
    }
    
    var keyWindowPresentedController: UIViewController? {
        var viewController = self.keyWindow?.rootViewController
        
        if let presentedController = viewController as? UITabBarController {
            viewController = presentedController.selectedViewController
        }
        
        while let presentedController = viewController?.presentedViewController {
            if let presentedController = presentedController as? UITabBarController {
                viewController = presentedController.selectedViewController
            } else {
                viewController = presentedController
            }
        }
        return viewController
    }
}

final class Interstitial: NSObject, GADFullScreenContentDelegate {
//     let adUnitID = "ca-app-pub-3940256099942544/4411468910" // test Id
    let adUnitID = "ca-app-pub-6235545617614297/7025402029" // produt Id
    private var interstitial: GADInterstitialAd?
    
    override init() {
        super.init()
        loadInterstitial()
    }
    
    func loadInterstitial(){
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID:adUnitID,
                                    request: request,
                          completionHandler: { [self] ad, error in
                            if let error = error {
                              print("Failed to load interstitial ad: \(error.localizedDescription)")
                              return
                            }
                            interstitial = ad
                            interstitial?.fullScreenContentDelegate = self
            print("debug4 : interstitial ready")
                          }
        )
    }
    
    /// Tells the delegate that the ad failed to present full screen content.
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
    }
    
    /// Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
        loadInterstitial()
    }
    
    func showAd(){
        let root = UIApplication.shared.windows.first?.rootViewController
        interstitial?.present(fromRootViewController: root!)
    }
}
