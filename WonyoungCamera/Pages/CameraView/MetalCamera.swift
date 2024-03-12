//
//  MetalCamera.swift
//  PhotoDiary
//
//  Created by 워뇨옹 on 2022/08/17.
//

import AVFoundation
class MetalCamera: ObservableObject {
    private var videoSession: AVCaptureSession = AVCaptureSession()
    private var cameraDevice: AVCaptureDevice?
    private var videoOutput: AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
    
    public var cameraPosition: AVCaptureDevice.Position = .back
    static let instance = MetalCamera()
    private init() {}

    func stopSession() {
        if videoSession.isRunning {
            videoSession.stopRunning()
        }
    }
    
    func startSession() {
        if !videoSession.isRunning {
            DispatchQueue.global().async {
                self.videoSession.startRunning()
            }
        }
    }
    
    func switchCamera() {
        self.videoSession.beginConfiguration()
        if cameraPosition == .back {
            cameraPosition = .front
        } else {
            cameraPosition = .back
        }
        guard let currentInput = self.videoSession.inputs.first as? AVCaptureDeviceInput else {
            return
        }
        self.videoSession.removeInput(currentInput)
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: cameraPosition){
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if videoSession.canAddInput(input) {
                    videoSession.addInput(input)
                }
            } catch {
                fatalError("[Camera] set up error!")
            }

        }
        
        var resolution: AVCaptureSession.Preset {
            if videoSession.canSetSessionPreset(.hd4K3840x2160) {
                return .hd4K3840x2160
            }
            if videoSession.canSetSessionPreset(.hd1920x1080) {
                return .hd1920x1080
            }
            return .hd1280x720
        }
        self.videoSession.sessionPreset = resolution
        self.videoSession.commitConfiguration()
    }

    func setUpCamera(delegate: AVCaptureVideoDataOutputSampleBufferDelegate?) {
        self.videoSession = AVCaptureSession()

        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: cameraPosition) {
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if videoSession.canAddInput(input) {
                    videoSession.addInput(input)
                }
            } catch {
                fatalError("[Camera] set up error!")
            }
        }
        videoOutput.videoSettings = [String(kCVPixelBufferPixelFormatTypeKey): kCVPixelFormatType_32BGRA]
        videoOutput.setSampleBufferDelegate(delegate, queue: DispatchQueue(label: "sample buffer delegate", attributes: []))
        if videoSession.canAddOutput(videoOutput) {
            videoSession.addOutput(videoOutput)
        }
        var resolution: AVCaptureSession.Preset {
            if videoSession.canSetSessionPreset(.hd4K3840x2160) {
                return .hd4K3840x2160
            }
            if videoSession.canSetSessionPreset(.hd1920x1080) {
                return .hd1920x1080
            }
            return .hd1280x720
        }
        self.videoSession.sessionPreset = resolution
        self.startSession()
    }
}

