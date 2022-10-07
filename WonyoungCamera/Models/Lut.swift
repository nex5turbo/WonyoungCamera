//
//  Lut.swift
//  YoungsCamera
//
//  Created by 워뇨옹 on 2022/08/24.
//

import Foundation
import MetalKit
enum Lut: String, CaseIterable {
    case Aladin, Alex, Amber, Anne, Antonio, Bob, Greg, Hagrid, Harry, Ivan, Jean, Josh, Karen, Lucas, Melissa, Peter, Salomon, Sara, Sophia, Tony

    case lut9, lut13, lut14, lut15, lut16, lut17, lut18, lut19, lut20, lut21, lut22
    
    case Harrison, Vinny, Olay, Gordon, Conny, Tom, Sampi, Logan, Henry, Porter, Agnes
    
    case Clementine, Blueberry, Dragon, Grapes, Apple, Pear, Strawberry
    
    case Danligter, Ranguit, Greered, Sven, Rangueen, Ragwarm, VIB, Garage, Yenely
    
    case Doris, Country, Doug, TinyDC, Blues, Borg, Earl, Coco, Minker, Carl, Sun, LemonFell
}

class LutStorage {
    static var instance = LutStorage()
    var luts: [Lut: MTLTexture]
    var selectedLut: Lut? = nil
    init() {
        let device = SharedMetalDevice.instance.device
        self.luts = [:]
        for lut in Lut.allCases {
            guard let texture = device.loadFilter(filterName: lut.rawValue) else {
                continue
            }
            self.luts[lut] = texture
        }
    }
    func applyRandomLut() {
        let lutKeys = Array(luts.keys)
        let randomIndex = Int.random(in: 0 ..< luts.count)
        self.selectedLut = lutKeys[randomIndex]
    }
}
