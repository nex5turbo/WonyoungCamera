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
    @Binding var decoration: Decoration
    @Binding var takePicture: Bool

    func makeUIView(context: Context) -> MetalView {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError()
        }
        let metalView = MetalView(self)
        metalView.metalLayer.device = device
        metalCamera.setUpCamera(delegate: metalView)
        return metalView
    }
    func updateUIView(_ uiView: MetalView, context: Context) {
    }
}

class MetalView: UIView {
    private var parent: MetalCameraView
    private var renderer: Renderer
    private var device: MTLDevice
    private var currentTexture: MTLTexture?
    private var currentPixelBuffer: CVPixelBuffer?

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

    init(_ parent: MetalCameraView) {
        self.parent = parent
        self.device = SharedMetalDevice.instance.device
        self.renderer = Renderer()
        super.init(frame: .zero)

        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(self.pinch))
        self.addGestureRecognizer(pinchGesture)
        self.isUserInteractionEnabled = true
        metalLayer.framebufferOnly = false
        start()
    }

    @objc func pinch(sender: UIPinchGestureRecognizer) {
        let scale = sender.scale
        
        parent.decoration.scale /= Float(scale)
        if parent.decoration.scale > 1 {
            parent.decoration.scale = 1
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
        renderer.render(
            to: currentDrawable,
            with: currentPixelBuffer,
            decoration: parent.decoration
        )
        if self.parent.takePicture {
            self.parent.takePicture = false
            saveCurrentTexture()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func saveCurrentTexture() {
        DispatchQueue.global().async {
            guard let texture = self.renderer.targetTexture else {
                return
            }
            guard let cgImage = convertToCGImage(texture: texture) else {
                fatalError("NO cgImage from texture")
            }
            let uiImage = UIImage(cgImage: cgImage)
            ImageManager.instance.saveImage(image: uiImage)
            if UserSettings.instance.saveOriginal {
                guard let texture = self.renderer.cameraTexture else { return }
                guard let cgImage = convertToCGImage(texture: texture) else { return }
                let uiImage = UIImage(cgImage: cgImage)
                UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
            }
        }
    }
}

extension MetalView: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        connection.isVideoMirrored = self.parent.metalCamera.cameraPosition == .front
        connection.videoOrientation = .portrait
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        self.currentPixelBuffer = pixelBuffer
        DispatchQueue.main.async {
            self.setNeedsDisplay()
        }
    }
}
