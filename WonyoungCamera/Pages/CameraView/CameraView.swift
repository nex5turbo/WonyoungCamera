//
//  CameraView.swift
//  YoungsCamera
//
//  Created by 워뇨옹 on 2022/08/22.
//

import SwiftUI
import AVFoundation

enum AdjustType {
    case brightness, contrast, saturation
}

struct CameraView: View {
    @ObservedObject var metalCamera: MetalCamera
    @ObservedObject var purchaseManager = PurchaseManager.shared
    
    @State var decoration: Decoration = Decoration.empty()

    @State var filterPresent = true
    @State var albumPresent = false
    @State var settingPresent = false
    
    
    @State var isMute = false
    @State var buttonColor: Color = .white
    @State var selectedAdjustType: AdjustType = .brightness
    @State var sliderValue: Float = 50
    @State var isSliderEditing = false

    let bottomIconSize: CGFloat = 25

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
                        settingPresent.toggle()
                    } label: {
                        Image(systemName: "gearshape.circle.fill")
                            .foregroundColor(self.buttonColor)
                            .font(.system(size:20))
                    }
                    Spacer()
                    Text(decoration.colorFilter.rawValue)
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
                        Color.black
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
                                decoration: $decoration
                            )
                        }
                        .cornerRadius(30)
                        .padding(.horizontal, 10)
                        VStack {
                            if UIScreen.main.bounds.height / UIScreen.main.bounds.width <= 2.0 {
                                Spacer()
                                Text(String.APP_NAME_SHORT)
                                    .font(.system(size: 25, weight: .bold))
                                    .foregroundColor(.black)
                            } else {
                                Text(String.APP_NAME_SHORT)
                                    .font(.system(size: 25, weight: .bold))
                                    .foregroundColor(.black)
                                Spacer()
                                Text(String.mindText)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.black)
                                    .padding(3)
                                Text(String.byUsText)
                                    .font(.system(size: 10))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()

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
                    .onChange(of: sliderValue) { newValue in
                        if newValue == 50 {
                            HapticManager.instance.impact(style: .soft)
                        }
                        decoration.setAdjustment(sliderValue, to: selectedAdjustType)
                    }
                    .onChange(of: selectedAdjustType) { newValue in
                        sliderValue = decoration.getAdjustment(of: selectedAdjustType)
                    }
                    .padding(.horizontal)
                    Color.clear.frame(height: 10)
                    
                    FilterScrollView(decoration: $decoration)
                    
                    HStack {
                        Button {
                            HapticManager.instance.impact(style: .soft)
                            self.metalCamera.switchCamera()
                        } label: {
                            Image(systemName: "arrow.triangle.2.circlepath.circle")
                                .font(.system(size: bottomIconSize))
                                .foregroundColor(self.buttonColor)
                                .padding(10)
                        }
                        Spacer()

                        Button {
                            HapticManager.instance.impact(style: .soft)
                            self.decoration.border.toggle()
                        } label: {
                            Image(systemName: !decoration.border ? "circle" : "circle.fill")
                                .font(.system(size: bottomIconSize))
                                .foregroundColor(self.buttonColor)
                                .padding(10)
                        }
                        Spacer()
                        Button {
                            if !purchaseManager.isPremiumUser, !decoration.colorFilter.isFree {
                                purchaseManager.subscriptionViewPresent.toggle()
                                return
                            }
                            HapticManager.instance.impact(style: .soft)
                            if !isMute {
                                shutterSound()
                            }
                            // take picture
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
                        NavigationLink(destination: AlbumView(), isActive: $albumPresent) {
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
        .background(Color.black)
        .onChange(of: albumPresent) { newValue in
            if newValue {
                metalCamera.stopSession()
            } else {
                metalCamera.startSession()
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView(metalCamera: MetalCamera())
    }
}
