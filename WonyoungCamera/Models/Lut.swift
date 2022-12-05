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
    case Aladin, Alex, Amber, Anne, Antonio, Bob, Greg, Hagrid, Harry, Ivan, Jean, Josh, Karen, Lucas, Melissa, Peter, Salomon, Sara, Sophia, Tony

    case lut9, lut13, lut14, lut15, lut16, lut17, lut18, lut19, lut20, lut21, lut22
    
    case Harrison, Vinny, Olay, Gordon, Conny, Tom, Sampi, Logan, Henry, Porter, Agnes
    
    case Clementine, Blueberry, Dragon, Grapes, Apple, Pear, Strawberry
    
    case Danligter, Ranguit, Greered, Sven, Rangueen, Ragwarm, VIB, Garage, Yenely
    
    case Doris, Country, Doug, TinyDC, Blues, Borg, Earl, Coco, Minker, Carl, Sun, LemonFell

    static fileprivate let lutInfo: [Lut] = [
        .Natural,
        .Aladin,
        .Alex,
        .Amber,
        .Anne
    ]

    var isFree: Bool {
        if Lut.lutInfo.contains(self) {
            return true
        }
        
        return false
    }
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

    func applyRandomLut() -> Lut {
        let lutKeys = Array(luts.keys)
        let randomIndex = Int.random(in: 0 ..< luts.count)
        self.selectedLut = lutKeys[randomIndex]
        return self.selectedLut
    }

    func getSampleImage(lut: MTLTexture) -> UIImage? {
        return renderer.applyLutToSampleImage(sampleImageTexture, lutTexture: lut)
    }
}
