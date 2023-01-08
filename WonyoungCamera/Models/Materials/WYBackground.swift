//
//  WYBackground.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2023/01/08.
//

import Foundation

struct WYBackground: WYMaterial {
    var id: String
    
    var path: String
    
    var category: String

    var thumbnailPath: String
    
    var name: String
    
    var isFree: Bool
    
    var createdAt: Date
    
    private enum CodingKeys: String, CodingKey {
        case id
        case path
        case category
        case name
        case createdAt
        case thumbnailPath
        case isFree
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        path = try values.decode(String.self, forKey: .path)
        name = try values.decode(String.self, forKey: .name)
        category = try values.decode(String.self, forKey: .category)
        createdAt = try values.decode(Date.self, forKey: .createdAt)
        thumbnailPath = try values.decode(String.self, forKey: .thumbnailPath)
        isFree = (try? values.decode(Bool.self, forKey: .isFree)) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(path, forKey: .path)
        try container.encode(name, forKey: .name)
        try container.encode(category, forKey: .category)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(thumbnailPath, forKey: .thumbnailPath)
        try container.encode(isFree, forKey: .isFree)
    }
}
