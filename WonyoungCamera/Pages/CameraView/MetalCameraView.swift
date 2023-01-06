//
//  MetalCameraView.swift
//  PhotoDiary
//
//  Created by 워뇨옹 on 2022/08/17.
//

import SwiftUI
import MetalKit
import AVFoundation

struct MetalCameraView: UIViewRepresentable {
    @ObservedObject var metalCamera: MetalCamera
    @Binding var shouldTakePicture: Bool
    @Binding var takenPicture: UIImage?
    @Binding var colorBackgroundEnabled: Bool
    @Binding var shouldStroke: Bool
    @Binding var colorBackgounrd: (Int, Int, Int)?
    func makeUIView(context: Context) -> MetalView {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError()
        }
        let metalView = MetalView(self, device: device)
        metalView.metalLayer.device = device
        metalCamera.setUpCamera(delegate: metalView)
        return metalView
    }
    func updateUIView(_ uiView: MetalView, context: Context) {
    }
    func makeCoordinator() -> Coordinator {
        
    }
}
class MetalView: UIView {
    private var parent: MetalCameraView
    private var textureCache: CVMetalTextureCache?
    private var device: MTLDevice
    private var currentTexture: MTLTexture?
    private var renderer: Renderer
    public var metalLayer: CAMetalLayer {
        return self.layer as! CAMetalLayer
    }
    override public class var layerClass: Swift.AnyClass {
        return CAMetalLayer.self
    }
    
    private var displayLink: CADisplayLink?

    func createDisplayLink() {
        guard displayLink == nil else { return }
        let displayLink = CADisplayLink(target: self, selector: #selector(onDisplay))
        displayLink.add(to: .main, forMode: .default)
        self.displayLink = displayLink
    }

    func destroyDisplayLink() {
        guard let displayLink = displayLink else { return }
        displayLink.isPaused = true
        displayLink.invalidate()
        self.displayLink = nil
    }

    @objc func onDisplay(displaylink: CADisplayLink) {
        setNeedsDisplay()
    }

    private var isStarting: Bool = false
    public func start() {
        guard isStarting == false else { return }
        
        createDisplayLink()
    }

    public func stop() {
        guard isStarting == true else { return }
        destroyDisplayLink()
    }

    init(_ parent: MetalCameraView, device: MTLDevice) {
        self.parent = parent
        self.device = device
        self.renderer = Renderer()
        super.init(frame: .zero)

        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(self.pinch))
        self.addGestureRecognizer(pinchGesture)
        self.isUserInteractionEnabled = true
        metalLayer.framebufferOnly = false
        if kCVReturnSuccess != CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, &textureCache) {
            print("[Error] CVMetalTextureCacheCreate")
        }
        start()
    }

    @objc func pinch(sender: UIPinchGestureRecognizer) {
        let scale = sender.scale
        
        parent.metalCamera.scale /= Float(scale)
        if parent.metalCamera.scale > 1 {
            parent.metalCamera.scale = 1
        }
        sender.scale = 1
    }
    public override func draw(_ rect: CGRect) {
    }

    // CALayerDelegate overrides
    override func display(_ layer: CALayer) {
        renderToMetalLayer()
    }

    override func draw(_ layer: CALayer, in ctx: CGContext) {
        renderToMetalLayer()
    }

    @objc func renderToMetalLayer() {
        guard let currentDrawable = metalLayer.nextDrawable() else { return }
        let shouldFlip = parent.metalCamera.cameraPosition == .front
        renderer.render(
            to: currentDrawable,
            with: currentTexture,
            shouldFlip: shouldFlip,
            scale: parent.metalCamera.scale,
            shouldStroke: parent.shouldStroke,
            clearColor: parent.colorBackgounrd == nil ? (255, 255, 255) : parent.colorBackgounrd!
        )
        
        DispatchQueue.main.async {
            if self.parent.shouldTakePicture {
                guard let texture = self.renderer.emptyTexture else {
                    return
                }
                guard let cgImage = convertToCGImage(texture: texture) else {
                    fatalError("NO cgImage from texture")
                }
                let uiImage = UIImage(cgImage: cgImage)
                self.parent.takenPicture = uiImage
                self.parent.shouldTakePicture = false
            }
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MetalView: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        connection.videoOrientation = .portrait
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))

        guard self.textureCache != nil else {
            return
        }

        // Create a Metal texture from the image buffer
        var cvTextureOut: CVMetalTexture?
        CVMetalTextureCacheCreateTextureFromImage(
            kCFAllocatorDefault,
            textureCache!,
            pixelBuffer,
            nil,
            .bgra8Unorm,
            CVPixelBufferGetWidth(pixelBuffer),
            CVPixelBufferGetHeight(pixelBuffer),
            0,
            &cvTextureOut
        )

        guard let cvTexture = cvTextureOut else {
            CVMetalTextureCacheFlush(textureCache!, 0)
            CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
            #if DEBUG
            fatalError("NO cvMetalTexture - makeTextureFromSampleBuffer")
            #else
            return
            #endif
        }
        guard let texture = CVMetalTextureGetTexture(cvTexture) else {
            CVMetalTextureCacheFlush(textureCache!, 0)
            CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
            #if DEBUG
            fatalError("NO texture - makeTextureFromSampleBuffer")
            #else
            return
            #endif
        }

        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0))) }
        self.currentTexture = texture
        // 배경색 변경
        if self.parent.colorBackgroundEnabled {
            let cameraImage = CIImage(cvPixelBuffer: pixelBuffer)
            let extent = cameraImage.extent
            let inputExtent = CIVector(x: extent.origin.x, y: extent.origin.y, z: extent.size.width, w: extent.size.height)
            if let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: cameraImage, kCIInputExtentKey: inputExtent]) {
                if let outputImage = filter.outputImage {
                    if let cgImage = convertToCGImage(ciImage: outputImage) {
                        self.parent.colorBackgounrd = cgImage[0, 0]
                    }
                }
            }
        } else {
            self.parent.colorBackgounrd = nil
        }

        DispatchQueue.main.async {
            self.setNeedsDisplay()
        }
    }
}
func textureToUIImage(texture: MTLTexture) -> UIImage? {
    guard let cgImage = convertToCGImage(texture: texture) else {
        return nil
    }
    let uiImage = UIImage(cgImage: cgImage)
    return uiImage
}
func convertToCGImage(texture: MTLTexture) -> CGImage? {
    let options: [CIImageOption: Any] = [
        .colorSpace: CGColorSpaceCreateDeviceRGB()
    ]
    guard let ciImage = CIImage(mtlTexture: texture, options: options) else {
        fatalError("No ciImage")
    }
    guard let cgImage = convertToCGImage(ciImage: ciImage.oriented(.downMirrored)) else {
        fatalError("No cgImage")
    }
    return cgImage
}
func convertToCGImage(ciImage: CIImage) -> CGImage? {
    let context = CIContext(options: nil)
    if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
        return cgImage
    }
    return nil
}

extension CGImage {

    subscript (x: Int, y: Int) -> (r: Int, g: Int, b: Int)? {

        if x < 0 || x > Int(width) || y < 0 || y > Int(height) {
            return nil
        }

        guard let provider = self.dataProvider else { return nil }
        guard let providerData = provider.data else { return nil }
        guard let data = CFDataGetBytePtr(providerData) else { return nil }

        let numberOfComponents = 4
        let pixelData = ((Int(width) * y) + x) * numberOfComponents

        let r = Int(data[pixelData])
        let g = Int(data[pixelData + 1])
        let b = Int(data[pixelData + 2])

        return (r, g, b)
    }
}
