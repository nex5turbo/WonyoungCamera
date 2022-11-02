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
    @State var resultNSData: NSData? = nil
    @State var resultData: Data? = nil
    @State var resultPresent = false
    @State var topBarHeight: CGFloat = 0
    @State var deleteConfirmPresent = false
    @State var selectedIndex = 0
    @Environment(\.dismiss) private var dismiss
    let deviceWidth = UIScreen.main.bounds.width
    let imageSize = UIScreen.main.bounds.width / 3.5
    var body: some View {
        ZStack {
            NavigationLink(destination: ExportResultView(resultImage: $resultImage, resultNSData: $resultNSData, resultData: $resultData), isActive: $resultPresent) {
                EmptyView()
            }
            ScrollView {
                Color.clear.frame(height: topBarHeight)
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
                                                self.selectedIndex = index
                                                self.deleteConfirmPresent = true
                                            } label: {
                                                Text("Delete")
                                                Image(systemName: "trash.circle")
                                            }
                                            Button {
                                                share(path: item.path)
                                            } label: {
                                                Text("Share")
                                                Image(systemName: "square.and.arrow.up.circle")
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
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "xmark.circle")
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
                .overlay(
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear {
                                self.topBarHeight = proxy.size.height
                            }
                            .onChange(of: proxy.size) { size in
                                self.topBarHeight = size.height
                            }
                    }
                )
                .background(.ultraThinMaterial)
                .onChange(of: isSelectMode) { newValue in
                    if !newValue {
                        selectedImages.removeAll()
                    }
                }
                Divider()
                Spacer()
            }
            if isSelectMode {
                VStack(spacing: 0) {
                    Spacer()
                    Divider()
                    VStack(spacing: 0) {
                        Color.clear.frame(height: 10)
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
                        Color.clear.frame(height: 5)
                        HStack {
                            Menu {
                                Button {
                                    export(as: .pdf)
                                } label: {
                                    Text("PDF")
                                    Image(systemName: "doc.circle")
                                }
                                Button {
                                    export(as: .png)
                                } label: {
                                    Text("PNG")
                                    Image(systemName: "photo.circle")
                                }
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
                        .edgesIgnoringSafeArea(.all)
                    }
                    .background(.ultraThinMaterial)
                }
            }
        }
        .alert("삭제하시겠습니까?", isPresented: $deleteConfirmPresent, actions: {
            Button(role: .destructive) {
                ImageManager.instance.delete(at: albumItems[selectedIndex].path)
                withAnimation {
                    albumItems.remove(at: self.selectedIndex)
                }
            } label: {
                Text("삭제")
            }
            Button(role: .cancel) {
            } label: {
                Text("취소")
            }
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
    func export(as ext: ExportType) {
        let exporter = Exporter()
        let paths = selectedImages.map { $0.path }
        guard let result = exporter.exportAndGetResult(paths: paths, as: ext, count: selectedExportCount.rawValue) else {
            return
        }
        self.resultImage = result.0
        self.resultNSData = result.1
        self.resultData = result.2
        self.resultPresent = true
        self.isSelectMode = false
    }
}

struct AlbumView_Previews: PreviewProvider {
    static var previews: some View {
        AlbumView()
    }
}

func share(path: String) {
    let url = NSURL(fileURLWithPath: path)
    let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
    activityVC.isModalInPresentation = true

    print(UIApplication.shared.connectedScenes)
    let scenes = UIApplication.shared.connectedScenes
    let windowScene = scenes.first as? UIWindowScene
    let window = windowScene?.windows.first
    window?.rootViewController?.present(activityVC, animated: true,completion: nil)
}

func share(data: Data) {
    let activityVC = UIActivityViewController(activityItems: [data], applicationActivities: nil)
    activityVC.isModalInPresentation = true

    print(UIApplication.shared.connectedScenes)
    let scenes = UIApplication.shared.connectedScenes
    let windowScene = scenes.first as? UIWindowScene
    let window = windowScene?.windows.first
    window?.rootViewController?.present(activityVC, animated: true,completion: nil)
}

func share(data: NSData) {
    let activityVC = UIActivityViewController(activityItems: [data], applicationActivities: nil)
    activityVC.isModalInPresentation = true

    print(UIApplication.shared.connectedScenes)
    let scenes = UIApplication.shared.connectedScenes
    let windowScene = scenes.first as? UIWindowScene
    let window = windowScene?.windows.first
    window?.rootViewController?.present(activityVC, animated: true,completion: nil)
}
