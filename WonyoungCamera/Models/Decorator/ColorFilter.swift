//
//  ColorFilter.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2023/01/08.
//

import Foundation
import Metal
import UIKit

protocol ColorFilter {
    var name: String { get }
    var isFree: Bool { get }
    var category: String { get }

    init(from decoder: Decoder) throws
    
    func apply(to texture: MTLTexture, with renderer: Renderer?) -> MTLTexture?
    func apply(to image: UIImage, with renderer: Renderer?) -> UIImage?
    func getSampleImage() -> UIImage?

    func encode(to encoder: Encoder) throws
}

struct LUTFilter: ColorFilter {
    var name: String
    var isFree: Bool
    var category: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case isFree
        case category
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try values.decode(String.self, forKey: .name)
        self.isFree = try values.decode(Bool.self, forKey: .isFree)
        self.category = try values.decode(String.self, forKey: .category)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(isFree, forKey: .isFree)
        try container.encode(category, forKey: .category)
    }
    
    func apply(to texture: MTLTexture, with renderer: Renderer?) -> MTLTexture? {
        return nil
    }
    
    func apply(to image: UIImage, with renderer: Renderer?) -> UIImage? {
        return nil
    }
    
    func getSampleImage() -> UIImage? {
        return nil
    }
}

struct BuiltInFilter: ColorFilter {
    var name: String
    var isFree: Bool
    var category: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case isFree
        case category
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try values.decode(String.self, forKey: .name)
        self.isFree = try values.decode(Bool.self, forKey: .isFree)
        self.category = try values.decode(String.self, forKey: .category)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(isFree, forKey: .isFree)
        try container.encode(category, forKey: .category)
    }
    
    func apply(to texture: MTLTexture, with renderer: Renderer?) -> MTLTexture? {
        return nil
    }
    
    func apply(to image: UIImage, with renderer: Renderer?) -> UIImage? {
        return nil
    }
    
    func getSampleImage() -> UIImage? {
        return nil
    }
}

