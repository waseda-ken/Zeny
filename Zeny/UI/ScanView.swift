//
//  ScanView.swift
//  Zeny
//
//  Created by 永田健人 on 2025/07/02.
//

import SwiftUI
import AVFoundation

struct ScanView: View {
    // カメラプレビュー用
    @State private var isSessionRunning = false
    private let session = AVCaptureSession()

    var body: some View {
        ZStack {
            CameraPreview(session: session)
                .edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                Button(action: startScan) {
                    Label("OCR開始", systemImage: "doc.text.viewfinder")
                        .padding()
                        .background(Circle().fill(Color.accentColor))
                        .foregroundColor(.white)
                        .font(.headline)
                        .shadow(radius: 4)
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear { configureSession() }
        .onDisappear { session.stopRunning() }
    }

    private func configureSession() {
        guard !isSessionRunning else { return }
        session.beginConfiguration()
        // カメラ入力デバイスを取得
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
           let input = try? AVCaptureDeviceInput(device: device),
           session.canAddInput(input) {
            session.addInput(input)
        }
        // 出力設定は後で OCR フレームワークに合わせて追加
        session.commitConfiguration()
        session.startRunning()
        isSessionRunning = true
    }

    private func startScan() {
        // OCR 処理呼び出し（Visionフレームワーク等）
        print("OCR処理を開始")
    }
}

// カメラプレビューを SwiftUI に埋め込むラッパー
struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        DispatchQueue.main.async {
            previewLayer.frame = view.bounds
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard let layer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer else { return }
        layer.frame = uiView.bounds
    }
}

struct ScanView_Previews: PreviewProvider {
    static var previews: some View {
        ScanView()
    }
}
