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
    case cancel
    case photo
    case arrowRight
    case finish
}

struct LottiView: UIViewRepresentable {
    @State private var animationView = LottieAnimationView()
    let lottieName: Lottie
    var loop: LottieLoopMode = .loop
    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: .zero)
        let bundle = Bundle.main
        guard let url = bundle.url(forResource: lottieName.rawValue, withExtension: "json") else {
            return view
        }
        guard let animation = try? JSONDecoder().decode(Animation.self, from: Data(contentsOf: url)) else {
            return view
        }
        DispatchQueue.main.async {
            animationView.animation = animation
            animationView.contentMode = .scaleAspectFit
            animationView.loopMode = loop
            
            animationView.play { isFinished in
                if isFinished {
                    animationView.removeFromSuperview()
                }
            }
            
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
        animationView.play { isFinished in
            if isFinished {
                animationView.removeFromSuperview()
            }
        }
    }
}
