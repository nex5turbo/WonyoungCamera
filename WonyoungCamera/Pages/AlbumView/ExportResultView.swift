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
                Image(systemName: "xmark")
                    .onTapGesture {
                        resultImage = UIImage()
                        resultNSData = nil
                        resultData = nil
                        dismiss()
                    }
                Spacer()
            }
            .padding()
            Spacer()
            Image(uiImage: resultImage)
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 400)
                .border(.black, width: 1)
            Spacer()
            HStack {
                Image(systemName: "square.and.arrow.up")
                    .onTapGesture {
                        if let data = resultData {
                            share(data: data)
                        } else if let nsdata = resultNSData {
                            share(data: nsdata)
                        }
                    }
            }
            .padding()
        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

//struct ExportResultView_Previews: PreviewProvider {
//    static var previews: some View {
//        ExportResultView()
//    }
//}
