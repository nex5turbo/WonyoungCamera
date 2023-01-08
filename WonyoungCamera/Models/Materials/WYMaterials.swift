//
//  WYMaterials.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2023/01/08.
//

import Foundation

protocol WYMaterial {
    var id: String { get }
    var path: String { get }
    var category: String { get }
    var name: String { get }
    var isFree: Bool { get }
    var createdAt: Date { get }
    var thumbnailPath: String { get }
}
