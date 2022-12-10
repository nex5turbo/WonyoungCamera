//
//  GradientImageView.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2022/12/10.
//

import SwiftUI

struct GradientImageView<Content: View>: View {
    @ViewBuilder var view: Content
    var gradient: LinearGradient = Color.mainGradientColor
    var body: some View {
        view
            .foregroundColor(.clear)
            .overlay {
                gradient
                    .mask(view)
            }
    }
}

//struct GradientImageView_Previews: PreviewProvider {
//    static var previews: some View {
//        GradientImageView()
//    }
//}
