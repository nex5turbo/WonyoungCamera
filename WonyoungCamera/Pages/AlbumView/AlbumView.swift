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
    @State var resultURL: String? = nil
    @State var resultPresent = false
    @State var deleteConfirmPresent = false
    @State var selectedIndex = 0
    @State var isLoading = false
    @Environment(\.dismiss) private var dismiss
    let deviceWidth = UIScreen.main.bounds.width
    @State var draggingItem: String?
    @State var isDragging = false
    
    init() {
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(.highlightColor)
        UISegmentedControl
            .appearance()
            .setTitleTextAttributes(
                [
                    .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
                    .foregroundColor: UIColor.white
                ],
                for: .selected
            )
        UISegmentedControl
            .appearance()
            .setTitleTextAttributes(
                [
                    .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
                    .foregroundColor: UIColor.black
                ],
                for: .normal
            )
    }
    var body: some View {
        ZStack {
            NavigationLink(destination: ExportResultView(resultImage: $resultImage, resultNSData: $resultNSData, resultURL: $resultURL), isActive: $resultPresent) {
                EmptyView()
            }
            VStack(spacing: 0) {
                ZStack {
                    HStack {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20))
                            .foregroundColor(.black)
                            .onTapGesture {
                                dismiss()
                            }
                            .padding()
                        Spacer()
                        Button {
                            withAnimation {
                                isSelectMode.toggle()
                            }
                            
                        } label: {
                            if !isSelectMode {
                                LottiView(lottieName: .exportImage)
                                    .frame(width: 44, height: 44)
                                    .padding(.vertical, 5)
                                    .padding(.horizontal, 10)
                            } else {
                                LottiView(lottieName: .photo)
                                    .frame(width: 44, height: 44)
                                    .padding(.vertical, 5)
                                    .padding(.horizontal, 10)
                                    
                            }
                        }
                        .disabled(isLoading)
                        .onChange(of: isSelectMode) { newValue in
                            if !newValue {
                                selectedImagePaths.removeAll()
                            }
                        }
                    }
                    HStack {
                        Text(String.appName)
                            .bold()
                            .font(.system(size: 20))
                            .foregroundColor(.black)
                    }
                }
                .background(.white)
                Divider()

                HStack(spacing: 0) {
                    if albumImagePaths.isEmpty {
                        Spacer()
                        VStack {
                            Spacer()
                            Text(String.noPhotoText)
                            Spacer()
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.flexible()),
                                                GridItem(.flexible()),
                                                GridItem(.flexible())]) {

                                ForEach(Array(zip(albumImagePaths.indices, albumImagePaths)), id: \.0) { (index, item) in
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
                                                        Text(String.deleteLabel)
                                                        Image(systemName: "trash.circle")
                                                    }
                                                    Button {
                                                        share(path: item)
                                                    } label: {
                                                        Text(String.shareLabel)
                                                        Image(systemName: "square.and.arrow.up.circle")
                                                    }
                                                    Button {
                                                        exportToAlbum(path: item)
                                                    } label: {
                                                        Text("Save to album")
                                                        Image(systemName: "photo.circle")
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
                            .padding()
                            Color.clear.frame(height: 200)
                        }
                    }
                    
                    if isSelectMode {
                        ScrollViewReader { scroll in
                            ScrollView(showsIndicators: false) {
                                
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
                                                        .foregroundColor(.black)
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
                                .onChange(of: selectedImagePaths) { _ in
                                    HapticManager.instance.impact(style: .soft)
                                }
                                
                                Color.clear.frame(height: 200)
                            }
                            .frame(width: 100)
                            .background(.thinMaterial)
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
                }
                .background(Color.white)
                if isLoading {
                    ProgressView()
                }
            }

            if isSelectMode {
                VStack(spacing: 0) {
                    Spacer()
                    if selectedImagePaths.isEmpty {
                        HStack(spacing: 0) {
                            Spacer()
                            LottiView(lottieName: .arrowRight)
                                .frame(width: 100, height: 100)
                            Color.clear.frame(width: 50)
                        }
                        Spacer()
                    }
                    Divider()
                    VStack(spacing: 0) {
                        Color.clear.frame(height: 10)
                        Picker(selection: $selectedExportCount, label: Text("")) {
                            ForEach(Array(ExportCount.allCases), id: \.self) { item in
                                switch item {
                                case ._3x4:
                                    Text("3x4")
                                        .onTapGesture {
                                            self.selectedExportCount = ._3x4
                                        }
                                case ._4x5:
                                    Text("4x5")
                                        .onTapGesture {
                                            self.selectedExportCount = ._4x5
                                        }
                                case ._5x6:
                                    Text("5x6")
                                        .onTapGesture {
                                            self.selectedExportCount = ._5x6
                                        }
                                }
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        Color.clear.frame(height: 5)
                        HStack {
                            Button {
                            } label: {
                                Image(systemName: "questionmark.circle")
                                    .accentColor(Color.highlightColor)
                                    .font(.system(size: 18))
                            }
                            .padding()

                            Spacer()
                            Text(selectedImagePaths.isEmpty ? String.selectLabel : String.selectedCountText(c1: selectedImagePaths.count, c2: selectedExportCount.rawValue))
                                .font(.system(size: 18))
                                .foregroundColor(.black)
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
                            .accentColor(Color.highlightColor)
                            .disabled(selectedImagePaths.isEmpty)
                        }
                        .padding(.bottom, 10)
                        .edgesIgnoringSafeArea(.all)
                    }
                    .background(.white)
                }
            }
        }
        .navigationBarHidden(true)
        .alert(String.askDeleteLabel, isPresented: $deleteConfirmPresent, actions: {
            Button(role: .destructive) {
                ImageManager.instance.delete(at: albumImagePaths[selectedIndex])
                albumImagePaths.remove(at: self.selectedIndex)
            } label: {
                Text(String.deleteLabel)
            }
            Button(role: .cancel) {
            } label: {
                Text(String.cancelLabel)
            }
        })
        .animation(.default, value: selectedIndex)
        .overlay(
            ImageViewer(image: $selectedImage, viewerShown: $fullscreenPresent)
        )
        .onAppear {
            isLoading = true
            DispatchQueue.global().async {
                if albumImagePaths.isEmpty {
                    self.albumImagePaths = ImageManager.instance.loadImageUrls()
                    self.isLoading = false
                } else {
                    self.isLoading = false
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
        self.resultURL = result.2
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
