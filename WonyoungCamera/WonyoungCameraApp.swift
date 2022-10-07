//
//  WonyoungCameraApp.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2022/09/22.
//

import SwiftUI
import AVFoundation

@main
struct WonyoungCameraApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


class AppDelegate: NSObject, UIApplicationDelegate {
        
    static var orientationLock = UIInterfaceOrientationMask.portrait //By default you want all your views to rotate freely

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            if response {
                
            } else {

            }
        }
        return true
    }
}
