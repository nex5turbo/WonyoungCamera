//
//  Lut.swift
//  YoungsCamera
//
//  Created by 워뇨옹 on 2022/08/24.
//

import Foundation
import MetalKit

enum Lut: String, CaseIterable {
    case Natural, Webtoon
    case J1, J2, J3, J4, J5, J6, J7, J8, J9, J10, J11, J12, J13, J14, J15, J16, J17, J18
}

class LutStorage {
    static var instance = LutStorage()
    var luts: [Lut: MTLTexture] = [:]
    var sampleImages: [Lut: UIImage?] = [:]
    var selectedLut: Lut = .Natural
    var sampleImageTexture: MTLTexture
    var sampleImage: UIImage
    let renderer: Renderer
    init() {
        let device = SharedMetalDevice.instance.device
        guard let sampleImageTexture = device.loadFilter(filterName: "sample") else {
            abort()
        }
        self.sampleImageTexture = sampleImageTexture
        self.renderer = Renderer(compute: "sampleImage")
        guard let sampleImage = UIImage(named: "sample") else {
            abort()
        }
        self.sampleImage = sampleImage
        for lut in Lut.allCases {
            guard let texture = device.loadFilter(filterName: lut.rawValue) else {
                continue
            }
            self.luts[lut] = texture
            guard let image = getSampleImage(lut: texture) else {
                continue
            }
            self.sampleImages[lut] = image
        }
    }

    func getTexture(_ lut: Lut) -> MTLTexture? {
        guard let texture = luts[lut] else {
            return nil
        }
        return texture
    }

    func getTexture(_ name: String) -> MTLTexture? {
        guard let lut = Lut(rawValue: name) else { return nil }
        return getTexture(lut)
    }

    func getSampleImage(lut: MTLTexture) -> UIImage? {
        return renderer.applyLutToSampleImage(sampleImageTexture, lutTexture: lut)
    }
}
