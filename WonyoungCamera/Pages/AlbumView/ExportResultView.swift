//
//  ExportResultView.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2022/11/02.
//

import SwiftUI

struct ExportResultView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var purchaseManager = PurchaseManager.shared
    @Binding var resultImage: UIImage
    @Binding var resultNSData: NSData?
    @Binding var resultData: Data?
    var body: some View {
        ZStack {
            ZStack {
                Image(uiImage: resultImage)
                    .resizable()
                    .scaledToFill()
                    .cornerRadius(15)
                    .frame(width: 300, height: 420)
                    .shadow(color: .gray, radius: 10, x: 5, y: 5)
                VStack {
                    LottiView(lottieName: .finish, loop: .playOnce)
                    Color.clear.frame(height: 120)
                }
            }
            VStack {
                Spacer()
                HStack {
                    Button {
                        if purchaseManager.isPremiumUser {
                            if let data = resultData {
                                share(data: data)
                            } else if let nsdata = resultNSData {
                                share(data: nsdata)
                            }
                        } else {
                            purchaseManager.subscriptionViewPresent.toggle()
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.up.circle")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                    }
                    .frame(width: 44, height: 44)
                    .background(Color.highlightColor)
                    .clipShape(Circle())
                }
            }
            VStack(spacing: 0) {
                ZStack {
                    HStack {
                        Text("Great!")
                            .bold()
                            .font(.system(size: 20))
                            .foregroundColor(.black)
                    }
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle")
                                .font(.system(size: 20))
                                .foregroundColor(.black)
                                .padding()
                        }
                        Spacer()
                    }
                }
                .background(.white)
                Divider()
                Spacer()
            }
        }
        
        .background(.white)
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

struct ExportResultView_Previews: PreviewProvider {
    static var previews: some View {
        ExportResultView(
            resultImage: .constant(UIImage()),
            resultNSData: .constant(nil),
            resultData: .constant(nil))
    }
}
