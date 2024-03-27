//
//  MetalCamera.swift
//  PhotoDiary
//
//  Created by 워뇨옹 on 2022/08/17.
//

import AVFoundation
class MetalCamera {
    private var videoSession: AVCaptureSession = AVCaptureSession()
    private var cameraDevice: AVCaptureDevice?
    private var videoOutput: AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
    
    public var cameraPosition: AVCaptureDevice.Position = .back
    public static let instance = MetalCamera()
    private init() {
        print("debug4 : init")
    }
    
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
            var resolution: AVCaptureSession.Preset {
                if device.supportsSessionPreset(.hd4K3840x2160) {
                    return .hd4K3840x2160
                }
                if device.supportsSessionPreset(.hd1920x1080) {
                    return .hd1920x1080
                }
                return .hd1280x720
            }
            self.videoSession.sessionPreset = resolution
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if videoSession.canAddInput(input) {
                    videoSession.addInput(input)
                }
            } catch {
                fatalError("[Camera] set up error!")
            }
        }
        self.videoSession.commitConfiguration()
    }

    func setUpCamera(delegate: AVCaptureVideoDataOutputSampleBufferDelegate?) {
        self.videoSession = AVCaptureSession()

        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: cameraPosition) {
            var resolution: AVCaptureSession.Preset {
                if device.supportsSessionPreset(.hd4K3840x2160) {
                    return .hd4K3840x2160
                }
                if device.supportsSessionPreset(.hd1920x1080) {
                    return .hd1920x1080
                }
                return .hd1280x720
            }
            self.videoSession.sessionPreset = resolution
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
        self.startSession()
    }
    
    
    func toggleTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        guard cameraPosition == .back else { return }
        if device.hasTorch {
            do {
                try device.lockForConfiguration()

                if on == true {
                    device.torchMode = .on
                } else {
                    device.torchMode = .off
                }

                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }
    
    /// auto focus at camera feed's specific point
    /// - Parameter point: CGPoint that desire to get focus
    func focus(at point: CGPoint) {
        guard let device = self.videoSession.inputs.first as? AVCaptureDeviceInput else { return }
        
        do {
            try device.device.lockForConfiguration()
            
        } catch {
            print("Could not lock device for configuration: \(error)")
        }
        if device.device.isFocusPointOfInterestSupported && device.device.isFocusModeSupported(.continuousAutoFocus) {
            device.device.focusPointOfInterest = point
            device.device.focusMode = .continuousAutoFocus
        }
        
        device.device.unlockForConfiguration()
    }
    
    /// zoom the camera feed
    /// - Parameter factor: Factor that scale value
    func zoom(factor: CGFloat) {
        guard let device = self.videoSession.inputs[0] as? AVCaptureDeviceInput else { return }
        let zoomFactor = min(max(device.device.videoZoomFactor * factor, 1.0), device.device.activeFormat.videoMaxZoomFactor)
        
        do {
            try device.device.lockForConfiguration()
            
        } catch {
            print("Could not lock device for configuration: \(error)")
        }
        device.device.ramp(toVideoZoomFactor: zoomFactor, withRate: 5.0)
        device.device.unlockForConfiguration()
    }
}

