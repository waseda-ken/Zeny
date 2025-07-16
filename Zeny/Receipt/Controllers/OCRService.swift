// Zeny/Receipt/Controllers/OCRService.swift
import UIKit
import Vision

final class OCRService {
    static let shared = OCRService()
    private init() {}

    /// 画像から文字列を認識して completion で返す
    func recognize(image: UIImage, completion: @escaping (String) -> Void) {
        guard let cgImage = image.cgImage else {
            completion("")
            return
        }
        let request = VNRecognizeTextRequest { req, err in
            DispatchQueue.main.async {
                if let e = err {
                    print("OCRエラー:", e)
                    completion("")
                } else {
                    let obs = req.results as? [VNRecognizedTextObservation] ?? []
                    let lines = obs.compactMap { $0.topCandidates(1).first?.string }
                    completion(lines.joined(separator: "\n"))
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
