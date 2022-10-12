//
//  CameraView.swift
//  YoungsCamera
//
//  Created by 워뇨옹 on 2022/08/22.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    enum AdjustType {
        case brightness, contrast, saturation
    }
    let bottomIconSize: CGFloat = 25
    @ObservedObject var metalCamera = MetalCamera()
    @State var shouldTakePicture = false
    @State var takenImage: UIImage? = nil
    @State var filterPresent = true
    @State var canTakeImage = true
    @State var brightness: Float = 1.0
    @State var saturation: Float = 1.0
    @State var contrast: Float = 1.0
    @State var isMute = false
    @State var colorBackgroundEnabled = false
    @State var settingPresent = false
    @State var colorBackground: (Int, Int, Int)? = nil
    @State var buttonColor: Color = .gray
    @State var selectedAdjustType: AdjustType = .brightness

    func setBrightness(dy: CGFloat) {
        let calculatedBrightness = dy / 10000
        brightness += Float(calculatedBrightness)
        if brightness <= 0.5 {
            brightness = 0.5
        } else if brightness >= 2.0 {
            brightness = 2.0
        }
    }
    func setContrast(dy: CGFloat) {
        let calculatedBrightness = dy / 10000
        contrast += Float(calculatedBrightness)
        if contrast <= 0.5 {
            contrast = 0.5
        }
    }
    func setSaturation(dy: CGFloat) {
        let calculatedBrightness = dy / 10000
        saturation += Float(calculatedBrightness)
        if saturation <= 0.5 {
            saturation = 0.5
        }
    }
    func getAdjustIconName() -> String {
        switch selectedAdjustType {
        case .brightness:
            return "microbe.circle"
        case .contrast:
            return "circle.righthalf.filled"
        case .saturation:
            return "drop.circle.fill"
        }
    }
    var body: some View {
        let drag = DragGesture()
            .onChanged {
                let startLocation = $0.startLocation.y
                let dy = startLocation - $0.location.y
                switch selectedAdjustType {
                case .brightness:
                    setBrightness(dy: dy)
                case .contrast:
                    setContrast(dy: dy)
                case .saturation:
                    setSaturation(dy: dy)
                }
            }
        // 근데 이걸 어떻게 자연스럽게 알릴 수 있으려나?
        ZStack {
            VStack {
                MetalCameraView(
                    metalCamera: metalCamera,
                    shouldTakePicture: $shouldTakePicture,
                    takenPicture: $takenImage,
                    brightness: $brightness,
                    contrast: $contrast,
                    saturation: $saturation,
                    colorBackgroundEnabled: $colorBackgroundEnabled,
                    colorBackgounrd: $colorBackground
                )
                .ignoresSafeArea()
            }
            .onChange(of: colorBackground?.0) { newValue in
                guard let color = colorBackground else {
                    self.buttonColor = .white
                    return
                }
                self.buttonColor = Color(red: Double(255 - color.0) / 255,
                                        green: Double(255 - color.1) / 255,
                                        blue: Double(255 - color.2) / 255)
            }

            VStack(spacing: 0) {
                HStack {
                    NavigationLink(destination: AlbumView().navigationTitle("").navigationBarHidden(true), isActive: $settingPresent) {
                        Image(systemName: "photo.circle")
                            .foregroundColor(self.buttonColor)
                            .font(.system(size: 20))
                            .padding(10)
                    }
                    Spacer()
                    Button {
                        HapticManager.instance.impact(style: .soft)
                        self.colorBackgroundEnabled.toggle()
                    } label: {
                        Image(systemName: colorBackgroundEnabled ? "circle.fill" : "circle.hexagongrid.circle")
                            .foregroundColor(self.buttonColor)
                            .font(.system(size:20))
                            .padding(10)
                    }
                    Spacer()
                    Button {
                        HapticManager.instance.impact(style: .soft)
                        self.isMute.toggle()
                    } label: {
                        Image(systemName: isMute ? "speaker.slash.circle.fill" : "speaker.wave.2.circle.fill")
                            .foregroundColor(self.buttonColor)
                            .font(.system(size:20))
                            .padding(10)
                    }
                }
                .padding()
                Spacer()
                VStack {
                    Color.clear.frame(height: 10)
                    if filterPresent {
                        FilterScrollView()
                    }
                    HStack {
                        Button {
                            HapticManager.instance.impact(style: .soft)
                            self.metalCamera.setUpCamera()
                        } label: {
                            Image(systemName: "arrow.triangle.2.circlepath.circle")
                                .font(.system(size: bottomIconSize))
                                .foregroundColor(self.buttonColor)
                                .padding(10)
                        }
                        Spacer()

                        Button {
                            HapticManager.instance.impact(style: .soft)
                            LutStorage.instance.applyRandomLut()
                        } label: {
                            Image(systemName: "shuffle.circle")
                                .font(.system(size: bottomIconSize))
                                .foregroundColor(self.buttonColor)
                                .padding(10)
                        }
                        Spacer()
                        Button {
                            HapticManager.instance.impact(style: .soft)
                            if !isMute {
                                shutterSound()
                            }
                            shouldTakePicture.toggle()
                        } label: {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(self.buttonColor)
                                .padding(10)
                        }
                        Spacer()
                        Button {
                            HapticManager.instance.impact(style: .soft)
                            switch selectedAdjustType {
                            case .brightness:
                                selectedAdjustType = .contrast
                            case .contrast:
                                selectedAdjustType = .saturation
                            case .saturation:
                                selectedAdjustType = .brightness
                            }
                        } label: {
                            Image(systemName: getAdjustIconName())
                                .font(.system(size: bottomIconSize))
                                .foregroundColor(self.buttonColor)
                                .padding(10)
                        }
                        Spacer()
                        Button {
                            HapticManager.instance.impact(style: .soft)
                            withAnimation {
                                filterPresent.toggle()
                            }
                        } label: {
                            Image(systemName: "camera.filters")
                                .font(.system(size: bottomIconSize))
                                .foregroundColor(self.buttonColor)
                                .padding(10)
                        }
                    }
                    Color.clear.frame(height: 10)
                }
                .padding()
                .cornerRadius(30, corners: [.topLeft, .topRight])
            }
            HStack {
                Spacer()
                Color(UIColor(red: 0, green: 0, blue: 0, alpha: 0.01))
                    .contentShape(Rectangle())
                    .frame(width: UIScreen.main.bounds.width, height: 300)
                    .gesture(drag)
                    .onTapGesture {
                        switch selectedAdjustType {
                        case .brightness:
                            brightness = 1
                        case .contrast:
                            contrast = 1
                        case .saturation:
                            saturation = 1
                        }
                    }
            }
        }
        .onChange(of: takenImage, perform: { newValue in
            if let newValue = newValue {
                canTakeImage = false
                DispatchQueue.global().async {
                    ImageManager.instance.saveImage(image: newValue)
                    DispatchQueue.main.async {
                        canTakeImage = true
                    }
                }
            }
        })
        .background(Color.white)
        .onChange(of: settingPresent) { newValue in
            if newValue {
                metalCamera.stopSession()
            } else {
                metalCamera.startSession()
            }
        }
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
