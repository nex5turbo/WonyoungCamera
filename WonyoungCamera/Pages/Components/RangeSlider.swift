//
//  RangeSlider.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2023/01/24.
//

import SwiftUI

struct RangeSlider: View {
    var systemName: String
    @Binding var value: Float
    var `in`: ClosedRange<Float> = 0...1
    var defaultValue: Float = 0.5
    var onEditingChanged: (Bool) -> Void = { _ in }
    var body: some View {
        HStack {
            Image(systemName: systemName)
                .font(.system(size: 22))
                .foregroundColor(.white)
            Slider(value: $value, in: `in`) { isEditing in
                onEditingChanged(isEditing)
            }
            HapticButton {
                value = defaultValue
            } content: {
                Image(systemName: "arrow.triangle.2.circlepath.circle")
                    .font(.system(size: 22))
            }
        }
    }
}

struct RangeSlider_Previews: PreviewProvider {
    static var previews: some View {
        RangeSlider(systemName: "", value: .constant(0))
    }
}
