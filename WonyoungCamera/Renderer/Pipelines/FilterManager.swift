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
        // pink baby
        filters.append(LovelyPipeline())
        filters.append(IdolPipeline())
        filters.append(FrigiaPipeline())
        filters.append(CreamPipeline())
        filters.append(ShinePipeline())
        
        // ground baby
        filters.append(WhisperVideoPipeline())
        filters.append(Sveltepipeline())
        filters.append(Pilotpipeline())
        filters.append(SilentPipeline())
        filters.append(PastPipeline())
        filters.append(HyphenPipeline())
        filters.append(HypnosisPipeline())
        
        // glassed cat
        filters.append(ArcadePipeline())
        filters.append(GangnamPipeline())
        filters.append(CK2Pipeline())
        filters.append(ReyesPipeline())
        filters.append(SiriPipeline())
        filters.append(BreadPipeline())
        filters.append(RiptonPipeline())
        
        // gray scale
        // hand raised cat
        filters.append(PenTouchPipeline())
        filters.append(MonoPipeline())
        // gray scale
        
        self.device = SharedMetalDevice.instance.device
        for filter in filters {
            sampleImages[filter.name] = getFilteredSampleImage(pipeline: filter)
        }
        let savedFilter = UserDefaults.standard.string(forKey: "filterName") ?? "Lovely"
        self.selectedFilter = filters.first { $0.name == savedFilter }
    }
    
    func selectFilter(_ filter: FilterPipeline) {
        UserDefaults.standard.setValue(filter.name, forKey: "filterName")
        self.selectedFilter = filter
    }
    
    func getFilteredSampleImage(pipeline: FilterPipeline) -> UIImage? {
        let array = pipeline.sampleImageName.split(separator: ".")
        print(array, pipeline.sampleImageName, pipeline.name)
        guard array.count > 1  else {
            return nil
        }
        let name = array[0]
        let ext = array[1]
        if let sampleImageTexture = device.loadImage(imageName: String(name), ext: String(ext)) {
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

extension String {
    static let sampleGlassedCat = "glassed_cat.jpg"
    static let sampleHandRaisedCat = "hand_raised_cat.jpg"
    static let sampleGroundBaby = "ground_baby.jpg"
    static let samplePinkBaby = "pink_baby.jpg"
}
