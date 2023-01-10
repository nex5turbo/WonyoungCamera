//
//  Lut.swift
//  YoungsCamera
//
//  Created by 워뇨옹 on 2022/08/24.
//

import Foundation
import MetalKit

enum Lut: String, CaseIterable {
    case Natural
    case JE1, JE2, JE3, JE4, JE5
    case JJ1, JJ2, JJ3, JJ4, JJ5
    case RD1, RD2, RD3, RD4
}

class LutStorage {
    static var instance = LutStorage()
    var luts: [Lut: MTLTexture] = [:]
    var sampleImages: [Lut: UIImage?] = [:]
    var selectedLut: Lut = .Natural
    let renderer: Renderer
    let device: MTLDevice
    let categories = ["Natural", "JE", "JJ", "RD"]
    let categoryMap: [String: String] = [
        "Natural": "sample",
        "JE": "cuteCat",
        "JJ": "smileDog",
        "RD": "colorfulWoman"
    ]
    init() {
        self.device = SharedMetalDevice.instance.device
        self.renderer = Renderer()
        for lut in Lut.allCases {
            guard let texture = device.loadFilter(filterName: lut.rawValue) else {
                continue
            }
            self.luts[lut] = texture
            guard let sampleName = getSampleImage(of: lut.rawValue) else {
                continue
            }
            guard let image = getSampleImage(sampleName: sampleName, lut: texture) else {
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

    func getSampleImage(sampleName: String, lut: MTLTexture) -> UIImage? {
        guard let sampleImageTexture = device.loadFilter(filterName: sampleName) else {
            return nil
        }
        return renderer.applyLutToSampleImage(sampleImageTexture, lutTexture: lut)
    }
    func getSampleImage(of filterName: String) -> String? {
        for category in categories {
            if filterName.contains(category) {
                return categoryMap[category]
            }
        }
        return nil
    }
}
