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
    @ObservedObject var purchaseManager = PurchaseManager.shared

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
    @State var buttonColor: Color = .white
    @State var selectedAdjustType: AdjustType = .brightness
    @State var sliderValue: Float = 0
    @State var isSliderEditing = false
    @State var selectedLut: Lut = .Natural

    func getAdjustIconName() -> String {
        switch selectedAdjustType {
        case .brightness:
            return "sun.max.circle"
        case .contrast:
            return "circle.righthalf.filled"
        case .saturation:
            return "drop.circle.fill"
        }
    }
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack {
                    Button {
                        HapticManager.instance.impact(style: .soft)
                        self.colorBackgroundEnabled.toggle()
                    } label: {
                        Image(systemName: colorBackgroundEnabled ? "circle.fill" : "circle.hexagongrid.circle")
                            .foregroundColor(self.buttonColor)
                            .font(.system(size:20))
                    }
                    Spacer()
                    Text(selectedLut.rawValue)
                        .foregroundColor(.gray)
                        .font(.system(size:15))
                    Spacer()
                    Button {
                        HapticManager.instance.impact(style: .soft)
                        self.isMute.toggle()
                    } label: {
                        Image(systemName: isMute ? "speaker.slash.circle.fill" : "speaker.wave.2.circle.fill")
                            .foregroundColor(self.buttonColor)
                            .font(.system(size:20))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .background(.black)
                GeometryReader { proxy in
                    ZStack {
                        Color.clear
                            .onAppear {
                                print(proxy.size.width)
                                print(proxy.size.height)
                            }
                            .onChange(of: proxy.size) { _ in
                                print(proxy.size.width)
                                print(proxy.size.height)
                            }
                        // metal view가 들어갈 자리
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
                        if isSliderEditing {
                            ZStack {
                                VStack {
                                    Image(systemName: getAdjustIconName())
                                        .foregroundColor(.white)
                                        .font(.system(size: 40))
                                    Text("\(Int(sliderValue))%")
                                        .foregroundColor(.white)
                                        .font(.system(size: 30))
                                }
                            }
                            .frame(width: 120, height: 120)
                            .background(.black.opacity(0.5))
                            .cornerRadius(10)
                        }
                    }
                    
                }
                VStack {
                    Color.clear.frame(height: 10)
                    Slider(value: $sliderValue, in: 0...100, step: 1) { editing in
                        self.isSliderEditing = editing
                    }
                        .accentColor(.white)
                        .onAppear {
                            self.sliderValue = 50
                        }
                        .onChange(of: sliderValue) { newValue in
                            if newValue == 50 {
                                HapticManager.instance.impact(style: .soft)
                            }
                            switch selectedAdjustType {
                            case .brightness:
                                brightness = 0.5 + (sliderValue / 100)
                            case .contrast:
                                contrast = 0.5 + (sliderValue / 100)
                            case .saturation:
                                saturation = 0.5 + (sliderValue / 100)
                            }
                        }
                        .onChange(of: selectedAdjustType) { newValue in
                            switch selectedAdjustType {
                            case .brightness:
                                sliderValue = (brightness - 0.5) * 100
                            case .contrast:
                                sliderValue = (contrast - 0.5) * 100
                            case .saturation:
                                sliderValue = (saturation - 0.5) * 100
                            }
                        }
                        .padding(.horizontal)
                    Color.clear.frame(height: 10)
                    if filterPresent {
                        FilterScrollView(selectedLut: $selectedLut, color: $buttonColor)
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
                            let selectedLut = LutStorage.instance.applyRandomLut()
                            self.selectedLut = selectedLut
                        } label: {
                            Image(systemName: "shuffle.circle")
                                .font(.system(size: bottomIconSize))
                                .foregroundColor(self.buttonColor)
                                .padding(10)
                        }
                        Spacer()
                        Button {
                            if !purchaseManager.isPremiumUser {
                                purchaseManager.subscriptionViewPresent.toggle()
                                return
                            }
                            HapticManager.instance.impact(style: .soft)
                            if !isMute {
                                shutterSound()
                            }
                            shouldTakePicture.toggle()
                        } label: {
                            ZStack {
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.highlightColor)
                                    .padding(10)
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.black)
                                    .padding(10)
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(self.buttonColor)
                                    .padding(10)
                            }
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
                        NavigationLink(destination: AlbumView(), isActive: $settingPresent) {
                            Image(systemName: "photo.circle")
                                .foregroundColor(self.buttonColor)
                                .font(.system(size: bottomIconSize))
                                .padding(10)
                        }
                    }
                    .padding(.horizontal)
                }
                .cornerRadius(30, corners: [.topLeft, .topRight])
                .background(.black)
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
