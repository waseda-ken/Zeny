//
// ReceiptScannerViewController.swift
// Zeny
//
// Created by 永田健人 on 2025/07/XX.
//

import UIKit
import AVFoundation
import Vision

final class ReceiptScannerViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    // MARK: - UI & AVSession
    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var resultTextView: UITextView!

    /// OCR完了時に呼び出すコールバック
    var onRecognized: ((String) -> Void)?

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupPreviewLayer()
        setupResultTextView()
        configureSession()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
        let height: CGFloat = 150
        resultTextView.frame = CGRect(
            x: 0,
            y: view.bounds.height - height,
            width: view.bounds.width,
            height: height
        )
    }

    // MARK: - Setup

    private func setupPreviewLayer() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
    }

    private func setupResultTextView() {
        resultTextView = UITextView()
        resultTextView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        resultTextView.textColor = .white
        resultTextView.isEditable = false
        resultTextView.isSelectable = false
        view.addSubview(resultTextView)
    }

    private func configureSession() {
        captureSession.beginConfiguration()

        // カメラ入力
        guard
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let input = try? AVCaptureDeviceInput(device: device),
            captureSession.canAddInput(input)
        else {
            captureSession.commitConfiguration()
            return
        }
        captureSession.addInput(input)

        // ビデオ出力
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        guard captureSession.canAddOutput(dataOutput) else {
            captureSession.commitConfiguration()
            return
        }
        captureSession.addOutput(dataOutput)
        captureSession.commitConfiguration()
        captureSession.startRunning()
    }

    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }
        performOCR(on: UIImage(cgImage: cgImage))
    }

    // MARK: - OCR ＋ レシート領域検出

    private func performOCR(on image: UIImage) {
        guard let cg = image.cgImage else { return }

        // 1. レシート領域（矩形）を検出
        let rectReq = VNDetectRectanglesRequest { [weak self] req, _ in
            guard let self = self else { return }
            DispatchQueue.global(qos: .userInitiated).async {
                let cgImageToUse: CGImage

                if let obs = (req.results as? [VNRectangleObservation])?.first {
                    // 2. CIImage に変換し遠近補正
                    let ci = CIImage(cgImage: cg)
                    let corners: [String: CIVector] = [
                        "inputTopLeft":     CIVector(x: obs.topLeft.x * ci.extent.width,
                                                     y: obs.topLeft.y * ci.extent.height),
                        "inputTopRight":    CIVector(x: obs.topRight.x * ci.extent.width,
                                                     y: obs.topRight.y * ci.extent.height),
                        "inputBottomLeft":  CIVector(x: obs.bottomLeft.x * ci.extent.width,
                                                     y: obs.bottomLeft.y * ci.extent.height),
                        "inputBottomRight": CIVector(x: obs.bottomRight.x * ci.extent.width,
                                                     y: obs.bottomRight.y * ci.extent.height)
                    ]
                    let corrected = ci.applyingFilter(
                        "CIPerspectiveCorrection",
                        parameters: corners
                    )
                    let ciContext = CIContext()
                    cgImageToUse = ciContext.createCGImage(corrected, from: corrected.extent) ?? cg
                } else {
                    // 検出失敗時はオリジナルを使用
                    cgImageToUse = cg
                }

                // 3. 切り出した画像でOCR実行
                let ocrReq = VNRecognizeTextRequest { [weak self] ocrReq, err in
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        if let e = err {
                            self.resultTextView.text = "OCRエラー: \(e.localizedDescription)"
                        } else {
                            let lines = (ocrReq.results as? [VNRecognizedTextObservation])?
                                .compactMap { $0.topCandidates(1).first?.string }
                                ?? []
                            let text = lines.joined(separator: "\n")
                            self.resultTextView.text = text
                            self.onRecognized?(text)
                        }
                    }
                }
                ocrReq.recognitionLevel = .accurate
                ocrReq.usesLanguageCorrection = false
                ocrReq.recognitionLanguages = ["ja-JP", "en-US"]

                let handler2 = VNImageRequestHandler(
                    cgImage: cgImageToUse,
                    options: [:]
                )
                try? handler2.perform([ocrReq])
            }
        }

        // 矩形検出のパラメータ調整
        rectReq.maximumObservations = 1
        rectReq.minimumConfidence   = 0.8
        rectReq.minimumAspectRatio  = 0.3

        let handler = VNImageRequestHandler(cgImage: cg, options: [:])
        try? handler.perform([rectReq])
    }
}
