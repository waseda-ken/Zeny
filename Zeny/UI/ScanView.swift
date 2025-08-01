// UI/ScanView.swift
import SwiftUI

struct ScanView: View {
    /// レシートから得られた PurchaseRecord を親に返す
    let onSave: (PurchaseRecord) -> Void

    @State private var showSourceAction = false
    @State private var showCameraSheet  = false
    @State private var showPhotoSheet   = false
    @State private var recognizedText   = ""
    @State private var selectedImage: UIImage?
    @State private var parsedRecord: PurchaseRecord?
    @State private var navigateToEdit   = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color("GradientTop"), Color("GradientBottom")]),
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 24) {
                    Spacer()
                    Text("レシートをスキャン")
                        .font(.title2).bold()
                        .foregroundStyle(.white)

                    Button { showSourceAction = true } label: {
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 48))
                            .foregroundColor(.white)
                            .padding(36)
                            .background(Circle().fill(Color("AccentGold").opacity(0.7)))
                            .overlay(Circle().fill(.thinMaterial).opacity(0.3))
                            .overlay(Circle().stroke(Color("AccentGold"), lineWidth: 1))
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    }

                    Text("タップしてレシートを撮影または選択")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.9))
                    Spacer()
                }
                .padding(.horizontal, 40)
            }
            .confirmationDialog("画像ソースを選択", isPresented: $showSourceAction) {
                Button("写真を撮る")      { showCameraSheet = true }
                Button("フォトライブラリ"){ showPhotoSheet  = true }
                Button("キャンセル", role: .cancel) {}
            }
            .sheet(isPresented: $showCameraSheet) {
                ReceiptScannerViewControllerWrapper(recognizedText: $recognizedText)
            }
            .sheet(isPresented: $showPhotoSheet) {
                ImagePicker(image: $selectedImage, sourceType: .photoLibrary)
            }
            .onChange(of: recognizedText) { _, txt in
                guard !txt.isEmpty else { return }
                handleOCR(text: txt)
            }
            .onChange(of: selectedImage) { _, img in
                guard let ui = img else { return }
                OCRService.shared.recognize(image: ui) { txt in
                    DispatchQueue.main.async { recognizedText = txt }
                }
            }
            .navigationDestination(isPresented: $navigateToEdit) {
                if let rec = parsedRecord {
                    ManualInputView(record: rec, onSave: onSave)
                }
            }
        }
    }

    private func handleOCR(text: String) {
        let amount    = parseAmount(from: text)
        let storeName = parseStoreName(from: text)
        let date      = parseDate(from: text) ?? Date()
        parsedRecord = PurchaseRecord(
            storeName:    storeName,
            purchaseDate: date,
            totalAmount:  amount,
            category:     "食費"
        )
        showCameraSheet = false
        showPhotoSheet  = false
        navigateToEdit  = true
    }

    // MARK: - 金額解析
    private func parseAmount(from text: String) -> Double {
        let ns = text as NSString
        let pattern = "(?<=¥|￥)\\s*([\\d,]+(?:\\.\\d+)?)"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return 0 }
        var values: [Double] = []
        let range = NSRange(location: 0, length: ns.length)
        regex.enumerateMatches(in: text, options: [], range: range) { m, _, _ in
            guard let m = m, m.numberOfRanges >= 2 else { return }
            let raw = ns.substring(with: m.range(at: 1)).replacingOccurrences(of: ",", with: "")
            if let num = Double(raw) {
                values.append(num)
            }
        }
        return values.max() ?? 0
    }

    // MARK: - 店舗名解析
    private func parseStoreName(from text: String) -> String {
        for line in text.components(separatedBy: .newlines) {
            let t = line.trimmingCharacters(in: .whitespaces)
            if t.isEmpty { continue }
            if t.rangeOfCharacter(from: .decimalDigits) != nil { continue }
            if t.contains("TEL") || t.contains("〒") { continue }
            return t
        }
        return ""
    }

    // MARK: - 日付解析
    private func parseDate(from text: String) -> Date? {
        let lines = text.components(separatedBy: .newlines)
        let formats: [(pattern: String, format: String)] = [
            ("(20\\d{2})[\\/\\-.](\\d{1,2})[\\/\\-.](\\d{1,2})", "yyyy/M/d"),
            ("(\\d{1,2})[\\/\\-.](\\d{1,2})[\\/\\-.](\\d{2})",     "M/d/yy"),
            ("(20\\d{2})年(\\d{1,2})月(\\d{1,2})日",               "yyyy年M月d日")
        ]
        for line in lines.reversed() {
            for (pat, fmt) in formats {
                if let d = matchDate(in: line, pattern: pat, format: fmt) {
                    return d
                }
            }
        }
        return nil
    }

    private func matchDate(in text: String, pattern: String, format: String) -> Date? {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let ns = text as NSString
        if let m = regex.firstMatch(in: text, range: NSRange(location: 0, length: ns.length)) {
            let matched = ns.substring(with: m.range)
            let df = DateFormatter()
            df.locale = Locale(identifier: "ja_JP")
            df.dateFormat = format
            return df.date(from: matched)
        }
        return nil
    }
}
