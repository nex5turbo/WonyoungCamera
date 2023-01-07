//
//  ColorDecorator.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2023/01/07.
//

import Foundation
import UIKit

struct ColorDecorator: Decorator {
    var id: String
    var path: String
    func provide(_ done: (Renderable?) -> Void) {
        let fromLocal = true
        if fromLocal {
            
        } else {
            guard let url = URL(string: path) else {
                done(nil)
                return
            }
            guard let data = try? Data(contentsOf: url) else {
                done(nil)
                return
            }
            guard let image = UIImage(data: data) else {
                done(nil)
                return
            }
            done(ImageRenderable(image: image))
        }
    }
}
