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
    @State var isLoading = true
    var body: some View {
        NavigationView {
            if isLoading {
                ZStack {
                    Color.black.edgesIgnoringSafeArea(.all)
                    VStack {
                        Image("subIcon")
                            .resizable()
                            .frame(width: 200, height: 200)
                        GradientImageView {
                            Text("Rounder Camera")
                                .font(.system(size: 25))
                                .bold()
                        }
                    }
                }
                .transition(.opacity)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        withAnimation {
                            isLoading = false
                        }
                    })
                }
            } else {
                CameraView(metalCamera: metalCamera)
            }
        }
        .sheet(isPresented: $purchaseManager.subscriptionViewPresent, content: {
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
