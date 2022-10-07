//
//  FilterScrollView.swift
//  YoungsCamera
//
//  Created by 워뇨옹 on 2022/08/24.
//

import SwiftUI

struct FilterScrollView: View {
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ZStack {
                    Color.gray
                    Text("default")
                        .font(.system(size: 8))
                        .foregroundColor(.white)
                }
                .frame(width: 70, height: 70)
                .cornerRadius(5)
                .onTapGesture {
                    LutStorage.instance.selectedLut = nil
                }
                ForEach(Lut.allCases, id: \.self) { lut in
                    Button {
                        LutStorage.instance.selectedLut = lut
                    } label: {
                        Image(uiImage: UIImage(named: lut.rawValue)!)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
                            .clipped()
                            .cornerRadius(5)
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
