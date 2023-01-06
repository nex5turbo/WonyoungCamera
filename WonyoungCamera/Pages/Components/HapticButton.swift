//
//  HapticButton.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2023/01/06.
//

import SwiftUI

struct HapticButton<Content: View>: View {
    let style: UIImpactFeedbackGenerator.FeedbackStyle
    let action: () -> Void
    let content: () -> Content
    var body: some View {
        Button {
            HapticManager.instance.impact(style: style)
            action()
        } label: {
            content()
        }

    }
}

struct HapticButton_Previews: PreviewProvider {
    static var previews: some View {
        HapticButton(style: .soft) {
            print("Hello World")
        } content: {
            EmptyView()
        }

    }
}
