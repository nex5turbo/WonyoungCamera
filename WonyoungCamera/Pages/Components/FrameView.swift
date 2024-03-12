//
//  FrameView.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 3/13/24.
//

import SwiftUI

struct FrameView: View {
    @Binding var decoration: Decoration
    let scale = UIScreen.main.scale
    let imageSize: CGFloat = 60
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                LazyHStack {
                    Button {
                        decoration.frame = nil
                    } label: {
                        Color.white.frame(width: imageSize, height: imageSize)
                            .cornerRadius(10)
                    }
                    ForEach(Frames.allCases, id: \.self) { name in
                        if let image = UIImage(named: name.rawValue + ".png")?.preparingThumbnail(of: CGSize(width: imageSize * scale, height: imageSize * scale)) {
                            Button {
                                decoration.frame = name.rawValue
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

#Preview {
    ContentView()
}
