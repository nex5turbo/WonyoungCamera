//
//  OpenAd.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2022/11/12.
//

import Foundation
import GoogleMobileAds

final class OpenAd: NSObject, GADFullScreenContentDelegate {
   var appOpenAd: GADAppOpenAd?
   var loadTime = Date()
   
    override init() {
        super.init()
        loadAppOpenAd()
    }
   func loadAppOpenAd() {
       let request = GADRequest()
       GADAppOpenAd.load(
//                         withAdUnitID: "ca-app-pub-6235545617614297/1415165279", // product Id
                         withAdUnitID: "ca-app-pub-3940256099942544/5662855259", // test Id
                         request: request,
                         orientation: UIInterfaceOrientation.portrait,
                         completionHandler: { (appOpenAdIn, _) in
                           self.appOpenAd = appOpenAdIn
                           self.appOpenAd?.fullScreenContentDelegate = self
                           self.loadTime = Date()
                         })
   }
   
   func tryToPresentAd() {
       if let gOpenAd = self.appOpenAd {
           gOpenAd.present(fromRootViewController: (UIApplication.shared.windows.first?.rootViewController)!)
       } else {
           self.loadAppOpenAd()
       }
   }
   
   func wasLoadTimeLessThanNHoursAgo(thresholdN: Int) -> Bool {
       let now = Date()
       let timeIntervalBetweenNowAndLoadTime = now.timeIntervalSince(self.loadTime)
       let secondsPerHour = 3600.0
       let intervalInHours = timeIntervalBetweenNowAndLoadTime / secondsPerHour
       return intervalInHours < Double(thresholdN)
   }
   
   func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
       print("[OPEN AD] Failed: \(error)")
       loadAppOpenAd()
   }
   
   func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
       loadAppOpenAd()
       print("[OPEN AD] Ad dismissed")
   }
}
