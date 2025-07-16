//
// OCRService.swift
// Zeny
//
// Created by 永田健人 on 2025/07/XX.
//

import UIKit
import Vision

/// 画像から文字列を認識するサービス
final class OCRService {
    /// シングルトンインスタンス
    static let shared = OCRService()
    private init() {}

    /// 画像を渡すと認識文字列を completion で返す
    func recognize(image: UIImage, completion: @escaping (String) -> Void) {
        guard let cgImage = image.cgImage else {
            completion("")
            return
        }
        // Vision OCR リクエスト
        let request = VNRecognizeTextRequest { req, err in
            DispatchQueue.main.async {
                if let e = err {
                    print("OCR エラー:", e)
                    completion("")
                } else {
                    let observations = req.results as? [VNRecognizedTextObservation] ?? []
                    let lines = observations.compactMap { $0.topCandidates(1).first?.string }
                    let fullText = lines.joined(separator: "\n")
                    completion(fullText)
                }
            }
        }
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        request.recognitionLanguages = ["ja-JP","en-US"]

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }
}
