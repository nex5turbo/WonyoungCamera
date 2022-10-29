//
//  FilterScrollView.swift
//  YoungsCamera
//
//  Created by 워뇨옹 on 2022/08/24.
//

import SwiftUI

struct FilterScrollView: View {
    @State var selectedLut: Lut? = nil
    @Binding var color: Color
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                VStack {
                    ZStack {
                        Color.gray
                    }
                    .clipShape(Circle())
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "checkmark.circle")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .opacity(self.selectedLut == nil ? 1 : 0)
                            .foregroundColor(.white)
                    )

                    VStack {
                        Spacer()
                        Text("default")
                            .frame(width: 30)
                            .font(.system(size: 10))
                            .scaledToFill()
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                            .foregroundColor(color)
                    }
                    .frame(height: 15)
                }
                .padding(2)
                .onTapGesture {
                    HapticManager.instance.impact(style: .soft)
                    LutStorage.instance.selectedLut = nil
                    self.selectedLut = nil
                }
                ForEach(Lut.allCases, id: \.self) { lut in
                    if let image = LutStorage.instance.sampleImages[lut] {
                        VStack {
                            Button {
                                HapticManager.instance.impact(style: .soft)
                                LutStorage.instance.selectedLut = lut
                                self.selectedLut = lut
                            } label: {
                                Image(uiImage: image!)
                                    .resizable()
                                    .scaledToFill()
                                    .clipShape(Circle())
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Image(systemName: "checkmark.circle")
                                            .resizable()
                                            .frame(width: 40, height: 40)
                                            .opacity(self.selectedLut == lut ? 1 : 0)
                                            .foregroundColor(.white)
                                    )
                            }
                            VStack {
                                Spacer()
                                Text(lut.rawValue)
                                    .frame(width: 30)
                                    .font(.system(size: 10))
                                    .scaledToFill()
                                    .minimumScaleFactor(0.5)
                                    .lineLimit(1)
                                    .foregroundColor(color)
                            }
                            .frame(height: 15)
                        }
                    }
                }
            }
        }
    }
}

struct FilterScrollView_Previews: PreviewProvider {
    static var previews: some View {
        FilterScrollView(color: .constant(.black))
    }
}
