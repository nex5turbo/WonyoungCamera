//
//  SubscriptionView.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2022/12/04.
//

import SwiftUI
import SwiftyStoreKit
struct SubscriptionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var purchaseManager = PurchaseManager.shared
    @State var isPurchasing = false
    @State var isRotating = false
    @State var successAlertPresent = false
    @State var errorAlertPresent = false
    @State var detailPresent = false
    @State var errorDescription = ""
    var foreverAnimation: Animation {
        Animation.linear(duration: 5.0)
            .repeatForever(autoreverses: false)
    }
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            GradientView {
                                Image(systemName: "xmark.circle")
                                    .font(.system(size:20))
                            }
                        }
                        Spacer()
                    }
                    .padding()
                    Image("subIcon")
                        .resizable()
                        .frame(width: detailPresent ? 200 : 300, height: detailPresent ? 200 : 300)
                        .rotationEffect(Angle(degrees: isRotating ? 360 : 0))
                        .animation(foreverAnimation, value: isRotating)
                        .onAppear {
                            isRotating = true
                        }
                    Color.clear.frame(height: 8)
                    VStack(spacing: 8) {
                        GradientView {
                            Text(String.monthlyPlanName)
                                .font(.system(size: 17))
                                .bold()
                        }
                        Text(String.appreciateText)
                            .font(.system(size: 20))
                            .bold()
                    }
                    Spacer()
                    Text(String.priceText)
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                    Button {
                        isPurchasing = true
                        PurchaseManager.shared.purchaseMonthlyPremium { result in
                            switch result {
                            case .success:
                                purchaseManager.setUserPremium(as: true)
                                successAlertPresent.toggle()
                            case .deferred:
                                errorDescription = "Network error"
                                errorAlertPresent.toggle()
                            case .error(let error):
                                self.errorDescription = error.localizedDescription
                                errorAlertPresent.toggle()
                            }
                            isPurchasing = false
                        }
                    } label: {
                        Text(String.subscribeLabel)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .background(Color.mainGradientColor)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 5)
                    .alert(
                        errorDescription,
                        isPresented: $errorAlertPresent
                    ) {
                        Button(role: .cancel) {
                        } label: {
                            Text("Ok")
                        }

                    } message: {
                        Text(String.tryAgainText)
                    }
                    .alert(
                        "Congraturation!",
                        isPresented: $successAlertPresent
                    ) {
                        Button(role: .cancel) {
                            dismiss()
                        } label: {
                            Text("Ok")
                        }

                    } message: {
                        Text(String.subscribeSuccessText)
                    }
                    HStack {
                        Button {
                            UIApplication.shared.open(URL(string: "https://sites.google.com/view/rounder-terms/")!)
                        } label: {
                            Text("Terms of Use")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                        Text("/")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                        Button {
                            UIApplication.shared.open(URL(string: "https://sites.google.com/view/rounderprivacy/")!)
                        } label: {
                            Text("Privacy Policy")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                        Text("/")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                        Button {
                            isPurchasing = true
                            purchaseManager.restorePremium { result in
                                isPurchasing = false
                                if result {
                                    successAlertPresent = true
                                } else {
                                    errorAlertPresent = true
                                }
                            }
                        } label: {
                            Text("Restore")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                    }
                    Group {
                        Button {
                            detailPresent.toggle()
                        } label: {
                            GradientView {
                                Image(systemName: detailPresent ? "chevron.compact.up" : "chevron.compact.down")
                                    .frame(width: 44, height: 44)
                                    .font(.system(size: 22))
                            }
                        }
                        if detailPresent {
                            Text(String.subscriptionInfoText)
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 31.5)
                                .padding(.bottom, 17)
                        }
                    }
                }
            }
            .animation(.easeIn, value: detailPresent)
            if isPurchasing {
                ZStack {
                    Color.black.opacity(0.4)
                    VStack {
                        HStack {
                            Text("Loading....")
                                .foregroundColor(.black)
                            ProgressView()
                                .progressViewStyle(.circular)
                                .foregroundColor(.black)
                        }
                    }
                    .padding(20)
                    .background(.white)
                    .cornerRadius(10)
                }
                .edgesIgnoringSafeArea(.all)
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct SubscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionView()
    }
}
