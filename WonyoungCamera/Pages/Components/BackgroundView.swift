//
//  BackgroundView.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2023/02/06.
//

import SwiftUI

struct BackgroundView: View {
    @Binding var decoration: Decoration
    let scale = UIScreen.main.scale
    let imageSize: CGFloat = 60
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                LazyHStack {
                    Button {
                        decoration.background = nil
                    } label: {
                        Color.white.frame(width: imageSize, height: imageSize)
                            .cornerRadius(10)
                    }
                    ForEach(Backgrounds.allCases, id: \.self) { name in
                        if let image = UIImage(named: name.rawValue + ".jpg")?.preparingThumbnail(of: CGSize(width: imageSize * scale, height: imageSize * scale)) {
                            Button {
                                decoration.background = name.rawValue
                            } label: {
                                Image(uiImage: image)
                                    .resizable()
                                    .frame(width: imageSize, height: imageSize)
                                    .cornerRadius(10)
                            }
                        }
                    }
                }
                .padding()
            }
        }
    }
}

struct BackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        BackgroundView(decoration: .constant(Decoration.empty()))
    }
}
