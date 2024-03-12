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
        filters.append(MonoPipeline())
        filters.append(FrigiaPipeline())
        filters.append(CreamPipeline())
        filters.append(ShinePipeline())
        filters.append(WhisperVideoPipeline())
        filters.append(Sveltepipeline())
        filters.append(Pilotpipeline())
        filters.append(SilentPipeline())
        filters.append(PastPipeline())
        filters.append(HyphenPipeline())
        filters.append(ArcadePipeline())
        filters.append(HypnosisPipeline())
        filters.append(TempPipeline())
        filters.append(Temp2Pipeline())
        filters.append(Temp3Pipeline())
        filters.append(Temp4Pipeline())
        filters.append(Temp5Pipeline())
        filters.append(Temp6Pipeline())
        filters.append(Temp7Pipeline())
        
        self.device = SharedMetalDevice.instance.device
        for filter in filters {
//            sampleImages[filter.name] = getFilteredSampleImage(pipeline: filter)
            sampleImages[filter.name] = UIImage(named: "Natural")
        }
        self.selectedFilter = filters.first
    }
    
//    func getFilteredSampleImage(pipeline: FilterPipeline) -> UIImage? {
//        if let sampleImageTexture = device.loadImage(imageName: "bicycle", ext: "jpg") {
//            if let resultTexture = self.renderer.filterSampleImageTexture(texture: sampleImageTexture, pipeline: pipeline) {
//                return textureToUIImage(texture: resultTexture, orientation: .portrait)
//            } else {
//                return nil
//            }
//        } else {
//            return nil
//        }
//    }
}
