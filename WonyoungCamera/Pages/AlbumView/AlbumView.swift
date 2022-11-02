//
//  AlbumView.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2022/09/27.
//

import SwiftUI
import Photos
import LinkPresentation

enum ExportCount: Int, CaseIterable {
    case _3x4 = 12
    case _4x5 = 20
    case _5x6 = 30
}

struct AlbumView: View {
    @State var albumImagePaths: [String] = []
    @State var selectedPath: String?
    @State var selectedImage: Image?
    @State var albumItems: [AlbumItem] = []
    @State var fullscreenPresent = false
    @State var isSelectMode = false
    @State var selectedImages: [AlbumItem] = []
    @State var selectedExportCount: ExportCount = ._3x4
    @State var resultImage: UIImage = UIImage()
    @State var resultPresent = false
    @Environment(\.dismiss) private var dismiss
    let deviceWidth = UIScreen.main.bounds.width
    let imageSize = UIScreen.main.bounds.width / 3.5
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Image(systemName: "xmark")
                        .font(.system(size: 20))
                        .onTapGesture {
                            dismiss()
                        }
                        .padding()
                    Spacer()
                    Image(systemName: "printer.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.clear)
                        .padding()
                    Spacer()
                    Button {
                        isSelectMode.toggle()
                    } label: {
                        Text("\(isSelectMode ? "취소" : "스티커")")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                    }
                    .background(Color.gray)
                    .cornerRadius(15)
                    .padding()
                }
                .onChange(of: isSelectMode) { newValue in
                    if !newValue {
                        selectedImages.removeAll()
                    }
                }
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: imageSize)),
                                        GridItem(.adaptive(minimum: imageSize)),
                                        GridItem(.adaptive(minimum: imageSize))]) {
                        ForEach(Array(zip(albumItems.indices, albumItems)), id: \.0) { (index, item) in
                            if let image = item.image {
                                ZStack {
                                    Image(uiImage: image)
                                        .resizable()
                                        .frame(width: imageSize, height: imageSize)
                                        .contextMenu {
                                            if !isSelectMode {
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
                                    // 체크버튼
                                    VStack {
                                        if isSelectMode && selectedImages.contains(item) {
                                            Image(systemName: "checkmark.circle")
                                                .font(.system(size: 40))
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .frame(width: imageSize, height: imageSize)
                                    .background(.black.opacity(isSelectMode && selectedImages.contains(item) ? 0.5 : 0))
                                    .clipShape(Circle())
                                    .clipped()
                                }
                                .onTapGesture {
                                    if isSelectMode {
                                        if selectedImages.contains(item) {
                                            guard let removeItemIndex = selectedImages.firstIndex(of: item) else {
                                                return
                                            }
                                            selectedImages.remove(at: removeItemIndex)
                                        } else {
                                            guard selectedImages.count < selectedExportCount.rawValue else {
                                                return
                                            }
                                            selectedImages.append(item)
                                        }
                                    } else {
                                        self.selectedPath = item.path
                                        guard let originalImage = UIImage(contentsOfFile: item.path) else { return }
                                        self.selectedImage = Image(uiImage: originalImage)
                                        self.fullscreenPresent.toggle()
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .padding(.bottom, 200)
                }
            }
            if isSelectMode {
                VStack(spacing: 0) {
                    Spacer()
                    Divider()
                    Color.white.frame(height: 10)
                    HStack {
                        Spacer()
                        ForEach(Array(ExportCount.allCases), id: \.self) { item in
                            switch item {
                            case ._3x4:
                                Text("12")
                                    .onTapGesture {
                                        self.selectedExportCount = ._3x4
                                    }
                            case ._4x5:
                                Text("20")
                                    .onTapGesture {
                                        self.selectedExportCount = ._4x5
                                    }
                            case ._5x6:
                                Text("30")
                                    .onTapGesture {
                                        self.selectedExportCount = ._5x6
                                    }
                            }
                            Spacer()
                        }
                    }
                    .background(.white)
                    Color.white.frame(height: 5)
                    HStack {
                        Button {
                            let exporter = Exporter()
                            let paths = selectedImages.map { $0.path }
                            guard let resultImage = exporter.exportAndGetResult(paths: paths, as: .png, count: selectedExportCount.rawValue) else {
                                return
                            }
                            self.resultImage = resultImage
                            self.resultPresent = true
                            self.isSelectMode = false
                        } label: {
                            Image(systemName: "printer.fill")
                                .font(.system(size: 18))
                        }
                        .padding()
                        .disabled(selectedImages.isEmpty)
                        Spacer()
                        Text(selectedImages.isEmpty ? "항목 선택" : "\(selectedImages.count) / \(selectedExportCount.rawValue)장의 사진이 선택됨")
                            .font(.system(size: 18))
                            .bold()
                        Spacer()
                        Button {
                        } label: {
                            Image(systemName: "printer.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.clear)
                        }
                        .padding()
                        .disabled(true)
                    }
                    .padding(.bottom, 10)
                    .background(.white)
                    .edgesIgnoringSafeArea(.all)
                }
                
            }
        }
        .sheet(isPresented: $resultPresent, content: {
            Image(uiImage: resultImage)
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 400)
                .border(.black, width: 1)
        })
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
