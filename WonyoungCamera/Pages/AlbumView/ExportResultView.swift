//
//  ExportResultView.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2022/11/02.
//

import SwiftUI

struct ExportResultView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var purchaseManager = InAppPurchaseManager.shared
    @Binding var resultImage: UIImage
    @Binding var resultNSData: NSData?
    @Binding var resultURL: String?
    var body: some View {
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
                        Task {
                            let files = FileManager.default.getFilesAtDocument()
                            files.forEach { path in
                                guard let url = URL(string: path) else { return }
                                
                                do {
                                    try FileManager.default.removeItem(at: url)
                                } catch {
                                    print(error.localizedDescription)
                                    return
                                }
                                print("\(path) success \(FileManager.default.fileExists(atPath: path))")
                            }
                        }
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
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
            Image(uiImage: resultImage)
                .resizable()
                .scaledToFill()
                .cornerRadius(15)
                .frame(width: 300, height: 420)
                .shadow(color: .gray, radius: 10, x: 5, y: 5)
            Spacer()
            Text(String.sizeText)
                .font(.system(size: 23))
                .bold()
                .padding()
            Text(String.shareInfoText)
                .foregroundColor(.gray)
                .font(.system(size: 15))
                .padding(.horizontal, 32)
            Spacer()
            Button {
                if purchaseManager.isPremiumUser {
                    if let resultURL {
                        share(path: resultURL)
                    } else if let nsdata = resultNSData {
                        share(data: nsdata)
                    }
                } else {
                    purchaseManager.subscriptionViewPresent.toggle()
                }
            } label: {
                Text(String.shareLabel)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .background(Color.mainGradientColor)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 32)
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
            resultURL: .constant(nil))
    }
}
