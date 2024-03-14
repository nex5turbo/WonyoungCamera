//
//  FilterManager.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 3/12/24.
//

import Foundation
import Metal
import UIKit

class FilterManager: ObservableObject {
    @Published var selectedFilter: FilterPipeline? = nil
    @Published var selectedBackground: String = ""
    
    var filters: [FilterPipeline] = []
    var sampleImages: [String: UIImage?] = [:]
    
    var device: MTLDevice
    let renderer = Renderer()
    
    static let shared = FilterManager()
    
    private init() {
        filters.append(LovelyPipeline())
        filters.append(IdolPipeline())
        filters.append(ArcadePipeline())
        
        filters.append(FrigiaPipeline())
        filters.append(CreamPipeline())
        filters.append(ShinePipeline())
        filters.append(WhisperVideoPipeline())
        filters.append(Sveltepipeline())
        filters.append(Pilotpipeline())
        filters.append(SilentPipeline())
        filters.append(PastPipeline())
        filters.append(HyphenPipeline())
        filters.append(HypnosisPipeline())
        filters.append(GangnamPipeline())
        filters.append(CK2Pipeline())
        
        // gray scale
        filters.append(PenTouchPipeline())
        filters.append(MonoPipeline())
        // gray scale
        
        filters.append(ReyesPipeline())
        filters.append(SiriPipeline())
        filters.append(BreadPipeline())
        filters.append(RiptonPipeline())
        
        self.device = SharedMetalDevice.instance.device
        for filter in filters {
            sampleImages[filter.name] = getFilteredSampleImage(pipeline: filter)
        }
        self.selectedFilter = filters.first
    }
    
    func getFilteredSampleImage(pipeline: FilterPipeline) -> UIImage? {
        if let sampleImageTexture = device.loadImage(imageName: "sample", ext: "png") {
            if let result = self.renderer.applyFilter(to: sampleImageTexture, with: pipeline) {
                return result
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}
