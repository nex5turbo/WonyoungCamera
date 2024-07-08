//
//  ContentView.swift
//  YoungsCamera
//
//  Created by 워뇨옹 on 2022/08/22.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @ObservedObject var purchaseManager = InAppPurchaseManager.shared
    var body: some View {
        NavigationView {
            CameraView()
        }
        .sheet(isPresented: $purchaseManager.subscriptionViewPresent, content: {
            SubscriptionView()
        })
        .navigationViewStyle(.stack)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
