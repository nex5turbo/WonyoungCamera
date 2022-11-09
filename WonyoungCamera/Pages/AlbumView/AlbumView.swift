//
//  AlbumView.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2022/09/27.
//

import SwiftUI
import Photos
import LinkPresentation
import Kingfisher

enum ExportCount: Int, CaseIterable {
    case _3x4 = 12
    case _4x5 = 20
    case _5x6 = 30
}

struct AlbumView: View {
    @State var albumImagePaths: [String] = []

    @State var selectedPath: String?
    @State var selectedImage: Image?
    @State var fullscreenPresent = false
    @State var isSelectMode = false
    @State var selectedImagePaths: [String] = []
    @State var selectedExportCount: ExportCount = ._3x4
    @State var resultImage: UIImage = UIImage()
    @State var resultNSData: NSData? = nil
    @State var resultData: Data? = nil
    @State var resultPresent = false
    @State var topBarHeight: CGFloat = 0
    @State var deleteConfirmPresent = false
    @State var selectedIndex = 0
    @State var isLoading = false
    @Environment(\.dismiss) private var dismiss
    let deviceWidth = UIScreen.main.bounds.width
    @State var imageSize = UIScreen.main.bounds.width / 3.5
    @State var draggingItem: String?
    @State var isDragging = false
    var body: some View {
        ZStack {
            NavigationLink(destination: ExportResultView(resultImage: $resultImage, resultNSData: $resultNSData, resultData: $resultData), isActive: $resultPresent) {
                EmptyView()
            }
            if !isLoading {
                HStack(spacing: 0) {
                    ScrollView {
                        Color.clear.frame(height: topBarHeight)
                        LazyVGrid(columns: [GridItem(.flexible()),
                                            GridItem(.flexible()),
                                            GridItem(.flexible())]) {

                            ForEach(Array(zip(albumImagePaths.indices, albumImagePaths)), id: \.0) { (index, item) in
                                if true {
                                    ZStack {
                                        let resizingProcessor = DownsamplingImageProcessor(size: CGSize(width: 300, height: 300))
                                        KFImage(URL(string: item))
                                            .resizable()
                                            .setProcessor(resizingProcessor)
                                            .scaledToFill()
                                            .contextMenu {
                                                if !isSelectMode {
                                                    Button(role: .destructive) {
                                                        self.selectedIndex = index
                                                        self.deleteConfirmPresent = true
                                                    } label: {
                                                        Text(deleteLabel)
                                                        Image(systemName: "trash.circle")
                                                    }
                                                    Button {
                                                        share(path: item)
                                                    } label: {
                                                        Text(shareLabel)
                                                        Image(systemName: "square.and.arrow.up.circle")
                                                    }
                                                }
                                            }
                                    }
                                    .onDrag {
                                        draggingItem = item
                                        isDragging = true
                                        return NSItemProvider()
                                    }
                                    .onTapGesture {
                                        if isSelectMode {
                                            guard selectedImagePaths.count < selectedExportCount.rawValue else {
                                                return
                                            }
                                            selectedImagePaths.append(item)
                                        } else {
                                            self.selectedPath = item
                                            var path = item
                                            if item.contains("file://") {
                                                path = item.replacingOccurrences(of: "file://", with: "")
                                            }
                                            guard let originalImage = UIImage(contentsOfFile: path) else {
                                                print(item)
                                                return
                                            }
                                            self.selectedImage = Image(uiImage: originalImage)
                                            self.fullscreenPresent.toggle()
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        Color.clear.frame(height: 200)
                    }
                    if isSelectMode {
                        ScrollView {
                            Color.clear.frame(height: topBarHeight)

                            VStack {
                                ForEach(selectedImagePaths.indices, id: \.self) { index in
                                    let item = selectedImagePaths[index]
                                    let resizingProcessor = ResizingImageProcessor(referenceSize: CGSize(width: 300, height: 300))
                                    ZStack {
                                        KFImage(URL(string: item))
                                            .resizable()
                                            .setProcessor(resizingProcessor)
                                            .frame(width: 90, height: 90)
                                        HStack {
                                            Spacer()
                                            VStack {
                                                Image(systemName: "xmark.circle")
                                                    .font(.system(size: 14))
                                                    .onTapGesture {
                                                        selectedImagePaths.remove(at: index)
                                                    }
                                                Spacer()
                                            }
                                        }
                                    }
                                    .padding(3)
                                }
                            }

                            Color.clear.frame(height: 200)
                        }
                        .frame(width: 100)
                        .background(.ultraThinMaterial)
                        .onDrop(of: [.item], delegate: DragDelegate(
                            items: $selectedImagePaths,
                            draggingItem: $draggingItem,
                            isDragging: $isDragging,
                            callback: { dropItem in
                                if selectedImagePaths.count < selectedExportCount.rawValue {
                                    selectedImagePaths.append(dropItem)
                                }
                            }))
                    }
                }
            } else {
                Color.gray
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    Spacer()
                }
                .background(.ultraThinMaterial)
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
                        withAnimation {
                            isSelectMode.toggle()
                        }
                        
                    } label: {
                        Text("\(isSelectMode ? cancelLabel : stickerLabel)")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                    }
                    .onChange(of: isSelectMode, perform: { newValue in
                    })
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
                        selectedImagePaths.removeAll()
                        withAnimation {
                            imageSize = UIScreen.main.bounds.width / 3.5
                        }
                    } else {
                        withAnimation {
                            imageSize = (UIScreen.main.bounds.width - 100) / 3.5
                        }
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
                            Button {
                            } label: {
                                Image(systemName: "questionmark.circle")
                                    .font(.system(size: 18))
                            }
                            .padding()

                            Spacer()
                            Text(selectedImagePaths.isEmpty ? selectLabel : selectedCountText(c1: selectedImagePaths.count, c2: selectedExportCount.rawValue))
                                .font(.system(size: 18))
                                .bold()
                            Spacer()

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
                            .disabled(selectedImagePaths.isEmpty)
                        }
                        .padding(.bottom, 10)
                        .edgesIgnoringSafeArea(.all)
                    }
                    .background(.ultraThinMaterial)
                }
            }
        }
        .alert(askDeleteLabel, isPresented: $deleteConfirmPresent, actions: {
            Button(role: .destructive) {
                ImageManager.instance.delete(at: albumImagePaths[selectedIndex])
                withAnimation {
                    albumImagePaths.remove(at: self.selectedIndex)
                }
            } label: {
                Text(deleteLabel)
            }
            Button(role: .cancel) {
            } label: {
                Text(cancelLabel)
            }
        })
        .overlay(
            ImageViewer(image: $selectedImage, viewerShown: $fullscreenPresent)
        )
        .onAppear {
            isLoading = true
            DispatchQueue.global().async {
                if albumImagePaths.isEmpty {
                    self.albumImagePaths = ImageManager.instance.loadImageUrls()
                    DispatchQueue.main.async {
                        withAnimation {
                            self.isLoading = false
                        }
                    }
                } else {
                    isLoading = false
                }
            }
        }
    }
    func export(as ext: ExportType) {
        let exporter = Exporter()
        let paths = selectedImagePaths
        guard let result = exporter.exportAndGetResult(paths: paths, as: ext, count: selectedExportCount.rawValue) else {
            return
        }
        self.resultImage = result.0
        self.resultNSData = result.1
        self.resultData = result.2
        self.resultPresent = true
        self.isSelectMode = false
    }

    private struct DragDelegate: DropDelegate {
        var items: Binding<[String]>
        var draggingItem: Binding<String?>
        var isDragging: Binding<Bool>
        var callback: (String) -> Void

        func performDrop(info: DropInfo) -> Bool {
            isDragging.wrappedValue = false
            guard let item = draggingItem.wrappedValue else {
                draggingItem.wrappedValue = nil // <- HERE
                return true
            }
            draggingItem.wrappedValue = nil // <- HERE
            callback(item)
            return true
        }

        func dropUpdated(info: DropInfo) -> DropProposal? {
           return DropProposal(operation: .move)
        }
    }
}
//
//struct AlbumView_Previews: PreviewProvider {
//    static var previews: some View {
//        AlbumView()
//    }
//}

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
