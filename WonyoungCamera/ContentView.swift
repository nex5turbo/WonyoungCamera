//
//  ContentView.swift
//  YoungsCamera
//
//  Created by 워뇨옹 on 2022/08/22.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @ObservedObject var purchaseManager = PurchaseManager.shared
    @ObservedObject var metalCamera = MetalCamera()
    var body: some View {
        NavigationView {
            CameraView(metalCamera: metalCamera)
        }
        .fullScreenCover(isPresented: $purchaseManager.subscriptionViewPresent, content: {
            SubscriptionView()
        })
        .navigationViewStyle(.stack)
        .onChange(of: scenePhase, perform: { newValue in
            switch newValue {
            case .active:
                if purchaseManager.isPremiumUser {
                    purchaseManager.verifySubscription { _ in }
                }
            default:
                break
            }
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
