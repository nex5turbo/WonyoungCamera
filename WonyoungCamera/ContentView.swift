//
//  ContentView.swift
//  YoungsCamera
//
//  Created by 워뇨옹 on 2022/08/22.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var openAd: OpenAd
    @ObservedObject var purchaseManager = InAppPurchaseManager.shared
    @State var isRotating = false
    var foreverAnimation: Animation {
        Animation.linear(duration: 5.0)
            .repeatForever(autoreverses: false)
    }
    
    var canNext: Bool {
        openAd.didDismiss
    }
    @State private var temp: Bool = false
    var body: some View {
        NavigationView {
            CameraView()
//            if !temp {
//                ZStack {
//                    Color.black.edgesIgnoringSafeArea(.all)
//                    VStack {
//                        Image("subIcon")
//                            .resizable()
//                            .frame(width: 200, height: 200)
//                            .rotationEffect(Angle(degrees: isRotating ? 360 : 0))
//                            .animation(foreverAnimation, value: isRotating)
//                        GradientView {
//                            Text(String.APP_NAME)
//                                .font(.system(size: 25))
//                                .bold()
//                        }
//                    }
//                }
//                .transition(.opacity)
//                .onAppear {
//                    isRotating = true
//                }
//                .onDisappear {
//                    isRotating.toggle()
//                }
//            } else {
//                CameraView()
//            }
        }
        .sheet(isPresented: $purchaseManager.subscriptionViewPresent, content: {
            SubscriptionView()
        })
        .navigationViewStyle(.stack)
        .task {
            print("debug4 : \(openAd.didDismiss)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                temp.toggle()
            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
