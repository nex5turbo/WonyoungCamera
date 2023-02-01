//
//  RangeSlider.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2023/01/24.
//

import SwiftUI

struct RangeSlider: View {
    @Binding var decoration: Decoration
    var systemImageColor: Color = .white
    var onEditingChanged: (Bool) -> Void = { _ in }
    var body: some View {
        HStack {
            Image(systemName: decoration.selectedAdjustment.type.getIconName())
                .font(.system(size: 22))
                .foregroundColor(systemImageColor)
            Slider(
                value: $decoration.selectedAdjustment.currentValue,
                in: decoration.selectedAdjustment.range
            ) { isEditing in
                onEditingChanged(isEditing)
            }
            .onChange(of: decoration.selectedAdjustment.currentValue) { newValue in
                switch decoration.selectedAdjustment.type {
                case .exposure:
                    decoration.exposure.currentValue = newValue
//                case .brightness:
//                    decoration.brightness.currentValue = newValue
                case .contrast:
                    decoration.contrast.currentValue = newValue
                case .saturation:
                    decoration.saturation.currentValue = newValue
                case .whiteBalance:
                    decoration.whiteBalance.currentValue = newValue
                }
            }
            HapticButton {
                decoration.selectedAdjustment.reset()
            } content: {
                Image(systemName: "arrow.triangle.2.circlepath.circle")
                    .font(.system(size: 22))
            }
        }
    }
}

struct RangeSlider_Previews: PreviewProvider {
    static var previews: some View {
        RangeSlider(decoration: .constant(.empty()))
    }
}
