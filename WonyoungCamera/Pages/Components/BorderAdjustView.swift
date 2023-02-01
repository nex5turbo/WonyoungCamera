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
        VStack() {
            HStack {
                Image(systemName: "circle")
                    .font(.system(size: 22))
                    .foregroundColor(.gray)
                Slider(
                    value: $decoration.borderThickness
                )
                HapticButton {
                    decoration.borderThickness = 0.5
                } content: {
                    Image(systemName: "arrow.triangle.2.circlepath.circle")
                        .font(.system(size: 22))
                }
            }
            .accentColor(.gray)
            .padding()
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
                .padding()
            }
            .onChange(of: color) { newValue in
                decoration.borderColor = CodableColor(uiColor: UIColor(newValue))
            }
            Color.clear.frame(height: 30)
        }
        .padding(.bottom)
    }
}

struct BorderAdjustView_Previews: PreviewProvider {
    static var previews: some View {
        BorderAdjustView(decoration: .constant(.empty()))
    }
}
