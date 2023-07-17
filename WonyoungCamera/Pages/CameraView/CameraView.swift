//
//  CameraView.swift
//  YoungsCamera
//
//  Created by 워뇨옹 on 2022/08/22.
//

import SwiftUI
import AVFoundation
import Photos


struct CameraView: View {
    @ObservedObject var purchaseManager = InAppPurchaseManager.shared
    
    @State var decoration: Decoration = Decoration.empty()
    @State var takePicture: Bool = false
    @State var canTakePicture: Bool = true

    @State var filterPresent = true
    @State var albumPresent = false
    @State var settingPresent = false
    @State var permissionPresent = false
    @State var borderPresent = false
    
    @State var isMute = false
    @State var buttonColor: Color = .white
    @State var isSliderEditing = false

    let bottomIconSize: CGFloat = 25

    func switchSlider() {
        self.decoration.switchAdjustment()
    }
    var body: some View {
        ZStack {
            NavigationLink(
                isActive: $settingPresent) {
                    SettingView()
                } label: {
                    EmptyView()
                }

            VStack(spacing: 0) {
                HStack {
                    HapticButton {
                        settingPresent.toggle()
                    } content: {
                        Image(systemName: "gearshape.circle.fill")
                            .foregroundColor(self.buttonColor)
                            .font(.system(size:20))
                    }
                    Spacer()
                    GradientView {
                        Text(String.APP_NAME_SHORT)
                            .font(.system(size: 25, weight: .bold))
                    }
                    Spacer()
                    HapticButton {
                        self.isMute.toggle()
                    } content: {
                        Image(systemName: isMute ? "speaker.slash.circle.fill" : "speaker.wave.2.circle.fill")
                            .foregroundColor(self.buttonColor)
                            .font(.system(size:20))
                    }
                }
                .padding(.horizontal, 20)
                .background(.black)
                Spacer() 
                ZStack {
                    // metal view가 들어갈 자리
                    VStack {
                        MetalCameraView(
                            decoration: $decoration,
                            takePicture: $takePicture
                        )
                    }
                    .frame(height: UIScreen.main.bounds.width - 20)
                    .cornerRadius(30)
                    .padding(.horizontal, 10)

                    if isSliderEditing {
                        ZStack {
                            VStack {
                                Image(systemName: decoration.selectedAdjustment.type.getIconName())
                                    .foregroundColor(.white)
                                    .font(.system(size: 40))
                                Text("\(decoration.selectedAdjustment.presentValue)")
                                    .foregroundColor(.white)
                                    .font(.system(size: 30))
                            }
                        }
                        .frame(width: 120, height: 120)
                        .background(.black.opacity(0.5))
                        .cornerRadius(10)
                    }
                }
                Spacer()
                VStack {
                    Color.clear.frame(height: 10)
                    RangeSlider(
                        decoration: $decoration
                    ) { editing in
                        self.isSliderEditing = editing
                    }
                    .accentColor(.white)
                    .padding(.horizontal)
                    Color.clear.frame(height: 10)
                    
                    FilterScrollView(decoration: $decoration)
                    
                    HStack {
                        HapticButton {
                            MetalCamera.instance.switchCamera()
                        } content: {
                            Image(systemName: "arrow.triangle.2.circlepath.circle")
                                .font(.system(size: bottomIconSize))
                                .foregroundColor(self.buttonColor)
                                .padding(10)
                        }
                        Spacer()

                        HapticButton {
                            self.borderPresent.toggle()
                        } content: {
                            Image(systemName: "circle")
                                .font(.system(size: bottomIconSize))
                                .foregroundColor(self.buttonColor)
                                .padding(10)
                        }
                        Spacer()
                        HapticButton {
                            if canTakePicture {
                                canTakePicture = false
                                DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                                    DispatchQueue.main.async {
                                        canTakePicture = true
                                    }
                                }
                                if !purchaseManager.isPremiumUser &&
                                    decoration.background != nil {
                                    purchaseManager.subscriptionViewPresent.toggle()
                                    return
                                }
                                if !isMute {
                                    shutterSound()
                                }
                                if !takePicture {
                                    takePicture.toggle()
                                }
                            }
                        } content: {
                            ZStack {
                                GradientView {
                                    Image(systemName: "circle.fill")
                                        .font(.system(size: 50))
                                        .padding(10)
                                }
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
                        .disabled(!canTakePicture)
                        .alert("Please allow album usage permission!", isPresented: $permissionPresent) {
                            Button(String.settingLabel) {
                                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(settingsUrl)
                                }
                            }
                            Button(String.cancelLabel, role: .cancel) {
                                
                            }
                        }
                        Spacer()
                        HapticButton {
                            switchSlider()
                        } content: {
                            Image(systemName: decoration.selectedAdjustment.type.getIconName())
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
            BottomSheet(sheetPresent: $borderPresent) {
                DecorationView(decoration: $decoration)
            }
        }
        .background(Color.black)
        .onChange(of: albumPresent) { newValue in
            if newValue {
                MetalCamera.instance.stopSession()
            } else {
                MetalCamera.instance.startSession()
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
