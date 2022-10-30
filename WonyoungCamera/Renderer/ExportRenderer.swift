//
//  ExportRenderer.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2022/10/31.
//

import Foundation
import MetalKit

class ExportRenderer {
    private var device: MTLDevice
    private var deviceSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    private var deviceScale = UIScreen.main.scale
    var computePipelineState12: MTLComputePipelineState
    var computePipelineState24: MTLComputePipelineState
    var computePipelineState40: MTLComputePipelineState
    var commandQueue: MTLCommandQueue
    var computeWith: [Int: MTLComputePipelineState]
    deinit {
        print("deinit renderer")
    }
    init() {
        self.device = SharedMetalDevice.instance.device
        guard let commandQueue = device.makeCommandQueue() else {
            fatalError("[Error] No command queue for device: \(device)")
        }
        self.commandQueue = commandQueue

        guard let computePipelineState12 = device.loadComputePipelineState("export12") else {
            fatalError()
        }
        self.computePipelineState12 = computePipelineState12
        guard let computePipelineState24 = device.loadComputePipelineState("export24") else {
            fatalError()
        }
        self.computePipelineState24 = computePipelineState24
        guard let computePipelineState40 = device.loadComputePipelineState("export40") else {
            fatalError()
        }
        self.computePipelineState40 = computePipelineState40
        self.computeWith = [
            12: computePipelineState12,
            24: computePipelineState24,
            40: computePipelineState40
        ]
    }
    func render(paths: [String], imageCount: Int) -> MTLTexture? {
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            print("[Error] no commandBuffer for commandQueue: \(commandQueue)")
            return nil
        }
        guard let computePipelineState = computeWith[imageCount] else {
            return nil
        }
        let textureWidth = 2100
        let textureHeight = 2970

        let textureDescriptor = MTLTextureDescriptor()
        textureDescriptor.textureType = .type2D
        textureDescriptor.pixelFormat = .bgra8Unorm
        textureDescriptor.width = textureWidth
        textureDescriptor.height = textureHeight
        textureDescriptor.usage = [.shaderRead, .shaderWrite, .renderTarget]
        guard let baseTexture = self.device.makeTexture(descriptor: textureDescriptor) else {
            return nil
        }

        var textures: [MTLTexture] = []
        for path in paths {
            guard let texture = device.loadImage(path: path) else {
                return nil
            }
            textures.append(texture)
        }
        while textures.count != imageCount {
            guard let texture = textures.last else {
                return nil
            }
            textures.append(texture)
        }

        let computeEncoder = commandBuffer.makeComputeCommandEncoder()
        computeEncoder?.setComputePipelineState(computePipelineState)
        computeEncoder?.setTexture(baseTexture, index: 0)
        computeEncoder?.setTextures(textures, range: 1..<textures.count + 1)
        let w = computePipelineState.threadExecutionWidth
        let h = computePipelineState.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSizeMake(w, h, 1)

        let threadgroupsPerGrid = MTLSizeMake((baseTexture.width + w - 1) / w,
                                         (baseTexture.height + h - 1) / h,
                                         1)
        computeEncoder?.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)

        computeEncoder?.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        return baseTexture
    }
}
