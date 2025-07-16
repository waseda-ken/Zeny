// UI/ScanView.swift
import SwiftUI

struct ScanView: View {
    @State private var showSourceAction = false
    @State private var useCamera = false
    @State private var showCameraSheet = false
    @State private var showPhotoSheet = false

    @State private var recognizedText = ""
    @State private var selectedImage: UIImage?
    @State private var parsedRecord: PurchaseRecord?
    @State private var showManualInput = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color("GradientTop"), Color("GradientBottom")]),
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 40) {
                    Text("レシートをスキャン")
                        .font(.title2).bold()
                        .foregroundStyle(.white)

                    Button { showSourceAction = true } label: {
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 48))
                            .padding(36)
                            .background(.thinMaterial, in: Circle())
                            .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 2))
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 6)
                            .scaleEffect(showSourceAction ? 1.05 : 1.0)
                            .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true),
                                       value: showSourceAction)
                    }

                    Text("または\nフォトライブラリから選択")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding()
            }
            .actionSheet(isPresented: $showSourceAction) {
                ActionSheet(title: Text("画像ソースを選択"), buttons: [
                    .default(Text("写真を撮る")) {
                        useCamera        = true
                        showCameraSheet  = true
                    },
                    .default(Text("フォトライブラリ")) {
                        useCamera       = false
                        showPhotoSheet  = true
                    },
                    .cancel()
                ])
            }
            .sheet(isPresented: $showCameraSheet) {
                ReceiptScannerViewControllerWrapper(recognizedText: $recognizedText)
            }
            .sheet(isPresented: $showPhotoSheet) {
                ImagePicker(image: $selectedImage, sourceType: .photoLibrary)
            }
            .onChange(of: recognizedText) { _, newText in
                guard !newText.isEmpty else { return }
                handleOCR(text: newText)
            }
            .onChange(of: selectedImage) { _, newImage in
                guard let img = newImage else { return }
                OCRService.shared.recognize(image: img) { text in
                    DispatchQueue.main.async {
                        self.recognizedText = text
                    }
                }
            }
            .navigationDestination(isPresented: $showManualInput) {
                if let record = parsedRecord {
                    ManualInputView(record: record) { saved in
                        print("保存されたレコード:", saved)
                    }
                } else {
                    EmptyView()
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
            totalAmount:  amount
        )
        showCameraSheet = false
        showPhotoSheet  = false
        showManualInput = true
    }

    // MARK: - 金額解析
    private func parseAmount(from text: String) -> Double {
        let ns = text as NSString
        let pattern = "(?<=¥|￥)\\s*([\\d,]+(?:\\.\\d+)?)"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return 0 }
        var values: [Double] = []
        regex.enumerateMatches(in: text, range: NSRange(location: 0, length: ns.length)) { m, _, _ in
            guard let m = m, m.numberOfRanges >= 2 else { return }
            let raw = ns.substring(with: m.range(at: 1)).replacingOccurrences(of: ",", with: "")
            if let num = Double(raw) { values.append(num) }
        }
        return values.max() ?? 0
    }

    // MARK: - 店舗名解析
    private func parseStoreName(from text: String) -> String {
        for line in text.components(separatedBy: .newlines) {
            let t = line.trimmingCharacters(in: .whitespaces)
            guard !t.isEmpty,
                  t.rangeOfCharacter(from: .decimalDigits) == nil,
                  !t.contains("TEL"),
                  !t.contains("〒")
            else { continue }
            return t
        }
        return ""
    }

    // MARK: - 日付解析
    private func parseDate(from text: String) -> Date? {
        let lines = text.components(separatedBy: .newlines)
        let dateFormats: [(pattern: String, format: String)] = [
            ("(20\\d{2})[\\/\\-.](\\d{1,2})[\\/\\-.](\\d{1,2})", "yyyy/M/d"),
            ("(\\d{1,2})[\\/\\-.](\\d{1,2})[\\/\\-.](\\d{2})",       "M/d/yy"),
            ("(20\\d{2})年(\\d{1,2})月(\\d{1,2})日",                  "yyyy年M月d日")
        ]
        for line in lines.reversed() {
            for (pat, fmt) in dateFormats {
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

struct ScanView_Previews: PreviewProvider {
    static var previews: some View {
        ScanView()
    }
}
