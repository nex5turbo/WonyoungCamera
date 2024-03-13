//
//  Backgrounds.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2023/02/06.
//

import Foundation
import MetalKit

enum Backgrounds: String, CaseIterable {
    case crb1, crb2, crb3, crb4, crb5, crb6
    case p1, p2, p3, p4
    case p_p1, p_p2, p_p3, p_p4, p_p5, p_p6, p_p7, p_p8, p_p9, p_p10
    func getImage() -> UIImage? {
        let array = self.rawValue.split(separator: "_")
        if array.count == 1 {
            return UIImage(named: self.rawValue + ".jpg")
        } else {
            if array.first == "p" {
                return UIImage(named: self.rawValue + ".png")
            }
        }
        return nil
    }
}

class BackgroundsStorage {
    static var instance = BackgroundsStorage()
    let device: MTLDevice
    
    init() {
        self.device = SharedMetalDevice.instance.device
    }

    func getTexture(_ name: String) -> MTLTexture? {
        if name.split(separator: "_").first == "p" {
            guard let texture = device.loadFilter(filterName: name, ext: "png") else { return nil }
            return texture
        } else {
            guard let texture = device.loadFilter(filterName: name, ext: "jpg") else { return nil }
            return texture
        }
    }
    
}
