//
//  AlbumView.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2022/09/27.
//

import SwiftUI
import Photos

struct AlbumView: View {
    @State var albumImagePaths: [String] = []
    @State var selectedPath: String?
    @State var albumItems: [AlbumItem] = []
    @State var fullscreenPresent = false
    @Environment(\.dismiss) private var dismiss
    let deviceWidth = UIScreen.main.bounds.width
    let imageSize = UIScreen.main.bounds.width / 3.5
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "xmark")
                    .font(.system(size: 20))
                    .onTapGesture {
                        dismiss()
                    }
                    .padding()
            }
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: imageSize)),
                                    GridItem(.adaptive(minimum: imageSize)),
                                    GridItem(.adaptive(minimum: imageSize))]) {
                    ForEach(Array(zip(albumItems.indices, albumItems)), id: \.0) { (index, item) in
                        if let image = item.image {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: imageSize, height: imageSize)
                                .onTapGesture {
                                    self.selectedPath = item.path
                                    self.fullscreenPresent.toggle()
                                }
                                .contextMenu {
                                    Button(role: .destructive) {
                                        withAnimation {
                                            albumItems.remove(at: index)
                                        }
                                        ImageManager.instance.delete(at: item.path)
                                    } label: {
                                        Text("Delete")
                                    }
                                }
                        }
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $fullscreenPresent, content: {
            FullScreenImageView(paths: $albumImagePaths ,path: $selectedPath)
        })
        .onAppear {
            DispatchQueue.global().async {
                if albumImagePaths.isEmpty {
                    self.albumImagePaths = ImageManager.instance.loadImageUrls()
                    self.albumImagePaths.forEach { path in
                        guard let image = UIImage(contentsOfFile: path)?.preparingThumbnail(of: CGSize(width: 300, height: 300)) else {
                            return
                        }
                        DispatchQueue.main.async {
                            withAnimation {
                                self.albumItems.append(AlbumItem(image: image, path: path))
                            }
                        }
                    }
                }
            }
        }
    }
}

struct AlbumView_Previews: PreviewProvider {
    static var previews: some View {
        AlbumView()
    }
}

