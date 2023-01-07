//
//  ThumbnailView.swift
//  WonyoungCamera
//
//  Created by Wonyoung Jang on 2023/01/06.
//

import SwiftUI

struct ThumbnailView: View {
    var path: String
    @State private var thumbnail: UIImage?
    var preferredThumbnailSize: CGFloat {
        return 480
    }
    var body: some View {
        ZStack {
            if let thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFill()
            }
        }
        .task {
            guard let url = URL(string: path) else {
                return
            }
            guard let data = try? Data(contentsOf: url) else {
                return
            }
            guard let image = UIImage(data: data) else {
                return
            }
            let scaleRatio = preferredThumbnailSize / image.size.width
            if let scaledImage = image.preparingThumbnail(of: image.size *= scaleRatio) {
                thumbnail = scaledImage
            } else {
                thumbnail = image
            }
        }
    }
}

struct ThumbnailView_Previews: PreviewProvider {
    static var previews: some View {
        ThumbnailView(path: "")
    }
}
