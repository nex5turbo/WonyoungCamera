//
//  FilterScrollView.swift
//  YoungsCamera
//
//  Created by 워뇨옹 on 2022/08/24.
//

import SwiftUI

struct FilterScrollView: View {
    @State var selectedLut: Lut? = nil
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 5) {
                ZStack {
                    Color.gray
                    Text("default")
                        .font(.system(size: 8))
                        .foregroundColor(.white)
                }
                .clipShape(Circle())
                .frame(width: 50, height: 50)
                .overlay(
                    Circle().stroke(self.selectedLut == nil ? .red : .clear, lineWidth: 3)
                )
                .padding(2)
                .onTapGesture {
                    LutStorage.instance.selectedLut = nil
                    self.selectedLut = nil
                }
                ForEach(Lut.allCases, id: \.self) { lut in
                    if let image = LutStorage.instance.sampleImages[lut] {
                        Button {
                            LutStorage.instance.selectedLut = lut
                            self.selectedLut = lut
                        } label: {
                            Image(uiImage: image!)
                                .resizable()
                                .scaledToFill()
                                .clipShape(Circle())
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Circle().stroke(self.selectedLut == lut ? .red : .clear, lineWidth: 3)
                                )
                                .padding(2)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

struct FilterScrollView_Previews: PreviewProvider {
    static var previews: some View {
        FilterScrollView()
    }
}
