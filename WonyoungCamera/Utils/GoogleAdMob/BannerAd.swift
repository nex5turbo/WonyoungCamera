//
//  BannerAd.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2023/07/16.
//

import Foundation
import GoogleMobileAds
import SwiftUI

struct GADBanner: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let view = GADBannerView(adSize: GADAdSizeBanner)
        let viewController = UIViewController()
        
        // product key
        view.adUnitID = "ca-app-pub-6235545617614297/2049596888"
        
        // test Key
//        view.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        view.rootViewController = viewController
        viewController.view.addSubview(view)
        viewController.view.frame = CGRect(origin: .zero, size: GADAdSizeBanner.size)
        view.load(GADRequest())
        return viewController
    }
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}
