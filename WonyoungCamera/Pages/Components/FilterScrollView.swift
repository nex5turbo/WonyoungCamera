//
//  FilterScrollView.swift
//  YoungsCamera
//
//  Created by 워뇨옹 on 2022/08/24.
//

import SwiftUI

struct FilterScrollView: View {
    @Binding var selectedLut: Lut
    @Binding var color: Color
    @State var isRotating = false
    @ObservedObject var purchaseManager = PurchaseManager.shared
    var foreverAnimation: Animation {
        Animation.linear(duration: 5.0)
            .repeatForever(autoreverses: false)
    }
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { value in
                HStack {
                    Section {
                        ForEach(Array(Lut.allCases).indices, id: \.self) { index in
                            let lut = Array(Lut.allCases)[index]
                            if let image = LutStorage.instance.sampleImages[lut] {
                                VStack {
                                    Button {
                                        HapticManager.instance.impact(style: .soft)
                                        LutStorage.instance.selectedLut = lut
                                        self.selectedLut = lut
                                    } label: {
                                        ZStack {
                                            Image(uiImage: image!)
                                                .resizable()
                                                .scaledToFill()
                                                .clipShape(Circle())
                                                .frame(width: 40, height: 40)
//                                            if lut.isFree {
//                                                Text("Free")
//                                                    .font(.system(size: 8, weight: .bold))
//                                                    .foregroundColor(.black)
//                                                    .background(.thinMaterial)
//                                                    .cornerRadius(3)
//                                            }
                                            Image(systemName: "checkmark.circle")
                                                .resizable()
                                                .frame(width: 40, height: 40)
                                                .opacity(self.selectedLut == lut ? 1 : 0)
                                                .foregroundColor(.white)
                                        }
                                    }
                                    VStack {
                                        Text(lut.rawValue)
                                            .frame(width: 30)
                                            .font(.system(size: 10))
                                            .scaledToFill()
                                            .minimumScaleFactor(0.5)
                                            .lineLimit(1)
                                            .foregroundColor(color)
                                    }
                                    .frame(height: 20)
                                }
                            }
                        }
                    } header: {
                        VStack {
                            Button {
                                purchaseManager.subscriptionViewPresent.toggle()
                            } label: {
                                Image("subIcon")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .rotationEffect(Angle(degrees: isRotating ? 360 : 0))
                                    .animation(foreverAnimation, value: isRotating)
                                    .onAppear {
                                        isRotating = true
                                    }
                            }
                            
                            VStack {
                                GradientImageView {
                                    Text("Subscribe")
                                        .frame(width: 30)
                                        .font(.system(size: 10, weight: .bold))
                                        .scaledToFill()
                                        .minimumScaleFactor(0.5)
                                        .lineLimit(1)
                                }
                            }
                            .frame(height: 20)
                        }
                        .background(.black)
                    }
                }
                .onChange(of: selectedLut) { newValue in
                    let scrollArray = Array(Lut.allCases)
                    guard let index = scrollArray.firstIndex(of: newValue) else {
                        return
                    }
                    withAnimation {
                        value.scrollTo(Int(index), anchor: .center)
                    }
                }
            }
        }
    }
}

struct FilterScrollView_Previews: PreviewProvider {
    static var previews: some View {
        FilterScrollView(selectedLut: .constant(Lut.Natural), color: .constant(.black))
    }
}
