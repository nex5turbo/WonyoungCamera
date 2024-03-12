//
//  AppOpen.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2023/07/16.
//

import GoogleMobileAds

final class OpenAd: NSObject, GADFullScreenContentDelegate {
    var appOpenAd: GADAppOpenAd?
    var loadTime = Date()
    
    func requestAppOpenAd() {
        let request = GADRequest()
//        GADAppOpenAd.load(withAdUnitID: "ca-app-pub-3940256099942544/3419835294", // test id
        GADAppOpenAd.load(withAdUnitID: "ca-app-pub-6235545617614297/6568492058", // product id
                          request: request,
                          completionHandler: { (appOpenAdIn, _) in
            self.appOpenAd = appOpenAdIn
            self.appOpenAd?.fullScreenContentDelegate = self
            self.loadTime = Date()
            if let gOpenAd = self.appOpenAd {
                gOpenAd.present(fromRootViewController: (UIApplication.shared.windows.first?.rootViewController)!)
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
//        requestAppOpenAd()
        print("[OPEN AD] Ad dismissed")
    }
    
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("[OPEN AD] Ad will present")
    }
}
