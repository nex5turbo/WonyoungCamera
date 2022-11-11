//
//  ExportResultView.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2022/11/02.
//

import SwiftUI

struct ExportResultView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var resultImage: UIImage
    @Binding var resultNSData: NSData?
    @Binding var resultData: Data?
    var body: some View {
        VStack {
            HStack {
                Button {
                    resultImage = UIImage()
                    resultNSData = nil
                    resultData = nil
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20))
                        .foregroundColor(.highlightColor)
                }
                Spacer()
            }
            .padding()

            Spacer()
            Image(uiImage: resultImage)
                .resizable()
                .scaledToFill()
                .cornerRadius(15)
                .frame(width: 300, height: 420)
                .shadow(color: .gray, radius: 10, x: 5, y: 5)
            Spacer()
            HStack {
                Button {
                    if let data = resultData {
                        share(data: data)
                    } else if let nsdata = resultNSData {
                        share(data: nsdata)
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
