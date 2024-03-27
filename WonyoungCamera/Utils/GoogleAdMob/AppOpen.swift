//
//  AppOpen.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2023/07/16.
//

import GoogleMobileAds

final class OpenAd: NSObject, GADFullScreenContentDelegate, ObservableObject {
    var appOpenAd: GADAppOpenAd?
    var loadTime = Date()
    @Published var didDismiss: Bool = false
    
    func requestAppOpenAd() {
        let request = GADRequest()
        var id = "ca-app-pub-6235545617614297/6568492058"
#if DEBUG
        id = "ca-app-pub-3940256099942544/3419835294"
#endif
        GADAppOpenAd.load(withAdUnitID: id,
                          request: request,
                          completionHandler: { (appOpenAdIn, _) in
            self.appOpenAd = appOpenAdIn
            self.appOpenAd?.fullScreenContentDelegate = self
            self.loadTime = Date()
            if let gOpenAd = self.appOpenAd {
                self.didDismiss = false
                gOpenAd.present(fromRootViewController: (UIApplication.shared.windows.first?.rootViewController)!)
            } else {
                self.didDismiss = true
            }
        })
    }
    
//    func tryToPresentAd() {
//        if let gOpenAd = self.appOpenAd, wasLoadTimeLessThanNHoursAgo(thresholdN: 4) {
//            gOpenAd.present(fromRootViewController: (UIApplication.shared.windows.first?.rootViewController)!)
//        } else {
//            self.requestAppOpenAd()
//        }
//    }
//
    func wasLoadTimeLessThanNHoursAgo(thresholdN: Int) -> Bool {
        let now = Date()
        let timeIntervalBetweenNowAndLoadTime = now.timeIntervalSince(self.loadTime)
        let secondsPerHour = 3600.0
        let intervalInHours = timeIntervalBetweenNowAndLoadTime / secondsPerHour
        return intervalInHours < Double(thresholdN)
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("[OPEN AD] Failed: \(error)")
//        requestAppOpenAd()
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        didDismiss = true
        print("[OPEN AD] Ad dismissed")
    }
    
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("[OPEN AD] Ad will present")
    }
}
