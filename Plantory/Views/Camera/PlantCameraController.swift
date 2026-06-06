//
//  PlantCameraController.swift
//  Plantory
//
//  Created by 纪洪波 on 2026/4/25.
//

import Observation
@preconcurrency import AVFoundation
import UIKit

@Observable
final class PlantCameraController: NSObject, AVCapturePhotoCaptureDelegate {
    nonisolated(unsafe) let session = AVCaptureSession()

    var capturedImage: PlatformImage?
    var isReady = false
    var isPhotoLibraryPresented = false
    private(set) var isFlashAvailable = false
    private(set) var flashMode: AVCaptureDevice.FlashMode = .off
    private(set) var zoomLabel = "1x"

    @ObservationIgnored private let sessionQueue = DispatchQueue(label: "Plantory.PlantCamera.Session")
    @ObservationIgnored nonisolated(unsafe) private let output = AVCapturePhotoOutput()
    @ObservationIgnored private var device: AVCaptureDevice?
    @ObservationIgnored private var zoomIndex = 0
    @ObservationIgnored private let zoomValues: [CGFloat] = [1, 2, 3]

    func start() async {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureAndStart()
        case .notDetermined:
            if await AVCaptureDevice.requestAccess(for: .video) {
                configureAndStart()
            }
        default:
            break
        }
    }

    func stop() {
        sessionQueue.async { [session] in
            if session.isRunning {
                session.stopRunning()
            }
        }
    }

    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        if output.supportedFlashModes.contains(flashMode) {
            settings.flashMode = flashMode
        }

        output.capturePhoto(with: settings, delegate: self)
    }

    func toggleFlash() {
        guard isFlashAvailable else { return }
        flashMode = flashMode == .off ? .on : .off
    }

    func toggleZoom() {
        guard let device else { return }
        zoomIndex = (zoomIndex + 1) % zoomValues.count
        let zoom = min(zoomValues[zoomIndex], device.activeFormat.videoMaxZoomFactor)

        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = zoom
            device.unlockForConfiguration()
            zoomLabel = "\(Int(zoom))x"
        } catch {
            zoomLabel = "1x"
        }
    }

    nonisolated func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        guard error == nil,
              let data = photo.fileDataRepresentation(),
              let photoImage = PlatformImage(data: data) else {
            return
        }

        Task { @MainActor in
            capturedImage = photoImage
        }
    }

    private func configureAndStart() {
        sessionQueue.async { [weak self] in
            guard let self else { return }

            if self.session.isRunning {
                Task { @MainActor in
                    self.isReady = true
                }
                return
            }

            self.session.beginConfiguration()
            self.session.sessionPreset = .photo
            self.session.inputs.forEach { self.session.removeInput($0) }
            self.session.outputs.forEach { self.session.removeOutput($0) }

            guard let cameraDevice = AVCaptureDevice.default(
                .builtInWideAngleCamera,
                for: .video,
                position: .back
            ),
                  let input = try? AVCaptureDeviceInput(device: cameraDevice),
                  self.session.canAddInput(input),
                  self.session.canAddOutput(self.output) else {
                self.session.commitConfiguration()
                return
            }

            self.session.addInput(input)
            self.session.addOutput(self.output)
            self.device = cameraDevice
            self.session.commitConfiguration()
            self.session.startRunning()

            Task { @MainActor in
                self.isFlashAvailable = cameraDevice.hasFlash
                self.flashMode = .off
                self.zoomIndex = 0
                self.zoomLabel = "1x"
                self.isReady = true
            }
        }
    }
}
