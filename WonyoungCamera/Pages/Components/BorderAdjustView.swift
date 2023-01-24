//
//  BorderAdjustView.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2023/01/24.
//

import SwiftUI

struct BorderAdjustView: View {
    @Binding var decoration: Decoration
    @State var color: Color = .black
    var body: some View {
        VStack {
            RangeSlider(systemName: "circle", value: $decoration.borderThickness, systemImageColor: color)
                .accentColor(color)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(Color.defaultColors, id: \.self) { currentColor in
                        Button {
                            color = currentColor
                        } label: {
                            currentColor
                                .clipShape(Circle())
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .stroke(.gray, lineWidth: 1)
                                )
                                .padding(1)
                        }
                    }
                }
            }
            .onChange(of: color) { newValue in
                decoration.borderColor = CodableColor(uiColor: UIColor(newValue))
            }
            Color.clear.frame(height: 30)
        }
        .padding()
    }
}

struct BorderAdjustView_Previews: PreviewProvider {
    static var previews: some View {
        BorderAdjustView(decoration: .constant(.empty()))
    }
}
