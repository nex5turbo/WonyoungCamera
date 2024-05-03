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
                        decoration.haveToBlur = false
                    } label: {
                        Color.white.frame(width: imageSize, height: imageSize)
                            .cornerRadius(10)
                    }
                    Button {
                        decoration.background = nil
                        decoration.haveToBlur = true
                    } label: {
                        ZStack {
                            Color.black
                            GradientView {
                                Text("BLUR")
                                    .bold()
                            }
                        }
                        .frame(width: imageSize, height: imageSize)
                        .cornerRadius(10)
                            
                    }
                    ForEach(Backgrounds.allCases, id: \.self) { background in
                        if let image = background.getImage()?.preparingThumbnail(of: CGSize(width: imageSize * scale, height: imageSize * scale)) {
                            Button {
                                decoration.background = background.rawValue
                                decoration.haveToBlur = false
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
