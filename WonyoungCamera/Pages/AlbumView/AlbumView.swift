//
//  AlbumView.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2022/09/27.
//

import SwiftUI
import Photos
import LinkPresentation

struct AlbumView: View {
    @State var albumImagePaths: [String] = []
    @State var selectedPath: String?
    @State var selectedImage: Image?
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
//                                    guard let originalImage = UIImage(contentsOfFile: item.path) else { return }
//                                    self.selectedImage = Image(uiImage: originalImage)
                                    let exporter = Exporter()
                                    exporter.export(paths: [item.path], as: .png, count: 12)
//                                    self.fullscreenPresent.toggle()
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
                                    Button {
                                        share(item: image, path: item.path)
                                    } label: {
                                        Text("Share")
                                    }
                                }
                        }
                    }
                }
                .padding()
            }
        }
        .overlay(
            ImageViewer(image: $selectedImage, viewerShown: $fullscreenPresent)
        )
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
    func share(item: UIImage, path: String) {
        guard let image = UIImage(contentsOfFile: path) else { return }
        let shareImage = ShareImage(placeholderItem: image)
        let activityVC = UIActivityViewController(activityItems: [shareImage], applicationActivities: nil)
        activityVC.isModalInPresentation = true

        print(UIApplication.shared.connectedScenes)
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        window?.rootViewController?.present(activityVC, animated: true,completion: nil)
    }
}

struct AlbumView_Previews: PreviewProvider {
    static var previews: some View {
        AlbumView()
    }
}

class ShareImage: UIActivityItemProvider {
    var image: UIImage

    override var item: Any {
        get {
          return self.image
        }
    }

override init(placeholderItem: Any) {
    guard let image = placeholderItem as? UIImage else {
        fatalError("Couldn't create image from provided item")
    }

    self.image = image
    super.init(placeholderItem: placeholderItem)
}

    @available(iOS 13.0, *)
    override func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {

        let metadata = LPLinkMetadata()
        metadata.title = "Share this circle!"

        var thumbnail: NSSecureCoding = NSNull()
        if let imageData = self.image.pngData() {
            thumbnail = NSData(data: imageData)
        }

        metadata.imageProvider = NSItemProvider(item: thumbnail, typeIdentifier: "public.png")

        return metadata
    }

}
