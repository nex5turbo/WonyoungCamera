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
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle")
                    }
                }
                .padding()
                Spacer()
                Text("Subscription needed")
                Button {
                    isPurchasing = true
                    PurchaseManager.shared.purchaseMonthlyPremium { result in
                        print(result)
                        switch result {
                        case .success:
                            purchaseManager.setUserPremium(as: true)
                        case .deferred:
                            break
                        case .error:
                            break
                        }
                        isPurchasing = false
                    }
                } label: {
                    Text("Subscribe")
                        .frame(maxWidth: .infinity)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .background(Color.highlightColor)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 5)
                Spacer()
                
            }
            if isPurchasing {
                ZStack {
                    Color.black.opacity(0.4)
                    VStack {
                        HStack {
                            Text("Loading....")
                            ProgressView()
                                .progressViewStyle(.circular)
                        }
                    }
                    .padding(20)
                    .background(.white)
                    .cornerRadius(10)
                }
                .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

struct SubscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionView()
    }
}
