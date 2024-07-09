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
    @State private var isAlbumPickerPresented: Bool = false
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                LazyHStack {
                    Button {
                        decoration.backgroundTexture = nil
                        decoration.haveToBlur = false
                    } label: {
                        Color.white.frame(width: imageSize, height: imageSize)
                            .cornerRadius(10)
                    }
                    
                    Button {
                        self.isAlbumPickerPresented.toggle()
                    } label: {
                        VStack {
                            GradientView {
                                Image(systemName: "photo.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: imageSize / 2, height: imageSize / 2)
                            }
                        }
                        .frame(width: imageSize, height: imageSize)
                        .background(.black)
                        .cornerRadius(10)
                    }
                    .sheet(isPresented: $isAlbumPickerPresented) {
                        ImagePicker { image in
                            decoration.backgroundImage = image
                        }
                    }
                    
                    Button {
                        decoration.backgroundTexture = nil
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
