//
//  FilterManager.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 3/12/24.
//

import Foundation

class FilterManager: ObservableObject {
    @Published var selectedFilter: FilterPipeline? = nil
    @Published var selectedBackground: String = ""
}
