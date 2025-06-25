import UIKit

struct OCRService {
    static let apiKey = "AIzaSyDZxYb4A-yoVRNYJj8rfvvufS_8sRiFOhE"  // ← ここをあなたの API キーに書き換え

    static func performOCR(image: UIImage, completion: @escaping (String) -> Void) {
        // 1. 画像を Base64 に
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            completion("画像変換に失敗しました")
            return
        }
        let base64 = data.base64EncodedString()

        // 2. リクエスト JSON
        let requestJSON: [String: Any] = [
            "requests": [[
                "image": ["content": base64],
                "features": [["type": "TEXT_DETECTION", "maxResults": 1]]
            ]]
        ]
        guard let url = URL(string:
            "https://vision.googleapis.com/v1/images:annotate?key=\(apiKey)"),
              let body = try? JSONSerialization.data(withJSONObject: requestJSON) else {
            completion("リクエストの構築に失敗しました")
            return
        }

        // 3. リクエスト実行
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = body

        URLSession.shared.dataTask(with: req) { data, resp, err in
            // (1) 通信エラーのチェック
            if let err = err {
                print("⚠️ 通信エラー:", err.localizedDescription)
                completion("通信エラー: \(err.localizedDescription)")
                return
            }

            // (2) HTTP ステータスコードを出力
            if let http = resp as? HTTPURLResponse {
                print("📡 ステータスコード:", http.statusCode)
            }

            // (3) 生の JSON を文字列でログに出力
            guard let data = data,
                  let raw = String(data: data, encoding: .utf8) else {
                completion("データ取得に失敗しました")
                return
            }
            print("🔍 Raw OCR JSON:\n\(raw)\n—")

            // 既存のパース処理に続く…

            // ★ まずは生JSONを返す
            completion("🔍 Raw OCR JSON:\n\(raw)")

            // 4. JSONパース
            do {
                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let responses = json["responses"] as? [[String: Any]],
                      let first = responses.first else {
                    completion("レスポンスフォーマットが不正です")
                    return
                }

                // TEXT_DETECTION なら textAnnotations
                if let annos = first["textAnnotations"] as? [[String: Any]],
                   let desc = annos.first?["description"] as? String {
                    completion(desc)
                    return
                }
                // DOCUMENT_TEXT_DETECTION なら fullTextAnnotation
                if let full = first["fullTextAnnotation"] as? [String: Any],
                   let text = full["text"] as? String {
                    completion(text)
                    return
                }

                completion("文字認識結果がありません")
            } catch {
                completion("JSON解析エラー: \(error.localizedDescription)")
            }
        }
        .resume()
    }
}
