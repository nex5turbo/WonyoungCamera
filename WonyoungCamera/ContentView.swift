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
    @State var isLoading = true
    @State var isRotating = false
    var foreverAnimation: Animation {
        Animation.linear(duration: 5.0)
            .repeatForever(autoreverses: false)
    }
    
    var body: some View {
        NavigationView {
            if isLoading {
                ZStack {
                    Color.black.edgesIgnoringSafeArea(.all)
                    VStack {
                        Image("subIcon")
                            .resizable()
                            .frame(width: 200, height: 200)
                            .rotationEffect(Angle(degrees: isRotating ? 360 : 0))
                            .animation(foreverAnimation, value: isRotating)
                        GradientView {
                            Text(String.APP_NAME)
                                .font(.system(size: 25))
                                .bold()
                        }
                    }
                }
                .transition(.opacity)
                .onAppear {
                    if isLoading {
                        
                        isRotating = true
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                            withAnimation {
                                isLoading = false
                            }
                        })
                    }
                }
            } else {
                CameraView()
            }
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
