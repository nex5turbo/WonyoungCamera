//
//  LottieView.swift
//  WonyoungCamera
//
//  Created by Wonyoung Jang on 2022/11/11.
//

import SwiftUI
import Lottie

enum Lottie: String {
    case exportImage
}

struct LottieThumbnailView: UIViewRepresentable {
    @State var animationView = LottieAnimationView()
    let lottieName: Lottie
    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: .zero)
        let bundle = Bundle.main
        guard let url = bundle.url(forResource: lottieName.rawValue, withExtension: "json") else {
            return view
        }
        let animation = try? JSONDecoder().decode(Animation.self, from: Data(contentsOf: url))
        DispatchQueue.main.async {
            animationView.animation = animation
            animationView.contentMode = .scaleAspectFit
            animationView.loopMode = .loop
            animationView.play()
            
            view.addSubview(animationView)

            animationView.translatesAutoresizingMaskIntoConstraints = false
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true

        }
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        guard !animationView.isAnimationPlaying else {
            return
        }
        animationView.play()
    }
}
