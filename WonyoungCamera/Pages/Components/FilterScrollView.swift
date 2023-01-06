//
//  FilterScrollView.swift
//  YoungsCamera
//
//  Created by 워뇨옹 on 2022/08/24.
//

import SwiftUI

struct FilterScrollView: View {
    @ObservedObject var purchaseManager = PurchaseManager.shared
    @Binding var decoration: Decoration

    @State var isRotating = false
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
                                        self.decoration.colorFilter = lut
                                    } label: {
                                        ZStack {
                                            Image(uiImage: image!)
                                                .resizable()
                                                .scaledToFill()
                                                .clipShape(Circle())
                                                .frame(width: 40, height: 40)
                                            GradientView {
                                                Image(systemName: "checkmark.circle")
                                                    .resizable()
                                                    .frame(width: 40, height: 40)
                                                    .opacity(self.decoration.colorFilter == lut ? 1 : 0)
                                            }
                                        }
                                    }
                                    VStack {
                                        Text(lut.rawValue)
                                            .frame(width: 30)
                                            .font(.system(size: 10))
                                            .scaledToFill()
                                            .minimumScaleFactor(0.5)
                                            .lineLimit(1)
                                            .foregroundColor(.white)
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
                                GradientView {
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
                .onChange(of: decoration.colorFilter) { newValue in
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
        FilterScrollView(decoration: .constant(.empty()))
    }
}
