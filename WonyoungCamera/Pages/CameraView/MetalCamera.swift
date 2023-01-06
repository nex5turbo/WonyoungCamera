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
    private var delegate: AVCaptureVideoDataOutputSampleBufferDelegate?
    
    public var cameraPosition: AVCaptureDevice.Position = .back

    var width: Int = 1080
    @Published var scale: Float = 1

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
    func setUpCamera() {
        guard let delegate = delegate else {
            return
        }
        if cameraPosition == .back {
            cameraPosition = .front
        } else {
            cameraPosition = .back
        }
        self.videoSession = AVCaptureSession()

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
        let videoOutput = AVCaptureVideoDataOutput()
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
        if resolution == .hd4K3840x2160 {
            self.width = 2160
        } else if resolution == .hd1920x1080 {
            self.width = 1080
        } else {
            self.width = 720
        }
        self.videoSession.sessionPreset = resolution
        self.startSession()
    }
    func setUpCamera(delegate: AVCaptureVideoDataOutputSampleBufferDelegate?) {
        guard let delegate = delegate else {
            return
        }
        self.delegate = delegate

        self.videoSession = AVCaptureSession()

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
        let videoOutput = AVCaptureVideoDataOutput()
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
        if resolution == .hd4K3840x2160 {
            self.width = 2160
        } else if resolution == .hd1920x1080 {
            self.width = 1080
        } else {
            self.width = 720
        }
        self.videoSession.sessionPreset = resolution
        self.startSession()
    }
}
