// UI/ScanView.swift
import SwiftUI

struct ScanView: View {
    @State private var showScanner = false
    @State private var recognizedText = ""              // OCR結果を受け取る
    @State private var parsedRecord: PurchaseRecord?    // パース後のレコード

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 1. スキャン開始ボタン
                Button("レシートをスキャン") {
                    showScanner = true
                }
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(8)

                // 2. OCR結果プレビュー
                if !recognizedText.isEmpty {
                    Text("OCR結果:")
                        .font(.headline)
                    ScrollView {
                        Text(recognizedText)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .frame(maxHeight: 200)

                    // 3. パースしてPurchaseRecordに変換
                    Button("登録画面へ進む") {
                        let amount = parseAmount(from: recognizedText)
                        let name   = parseStoreName(from: recognizedText)
                        parsedRecord = PurchaseRecord(
                            storeName: name,
                            purchaseDate: Date(),
                            totalAmount: amount
                        )
                    }
                    .disabled(parsedRecord != nil)
                    .padding(.top)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("スキャン")
            // 4. モーダルでUIViewControllerラッパーを呼び出し
            .sheet(isPresented: $showScanner) {
                ReceiptScannerViewControllerWrapper(recognizedText: $recognizedText)
            }
            // 5. parsedRecordがセットされたらRegisterViewへ遷移
            .background(
                NavigationLink(
                    destination: {
                        if let rec = parsedRecord {
                            RegisterView(record: rec) { saved in
                                // 保存後の処理（例: ViewModelへ渡すなど）
                                print("保存されたレコード:", saved)
                            }
                        } else {
                            EmptyView()
                        }
                    }(),
                    isActive: Binding(
                        get: { parsedRecord != nil },
                        set: { if !$0 { parsedRecord = nil } }
                    )
                ) {
                    EmptyView()
                }
                .hidden()
            )
        }
    }

    // MARK: - OCR文字列パース例

    private func parseAmount(from text: String) -> Double {
        // 数字と小数点だけ抽出
        let numString = text
            .components(separatedBy: CharacterSet(charactersIn: "0123456789.").inverted)
            .joined()
        return Double(numString) ?? 0
    }

    private func parseStoreName(from text: String) -> String {
        // 最初の行を店名とみなす
        text.components(separatedBy: "\n").first ?? ""
    }
}

struct ScanView_Previews: PreviewProvider {
    static var previews: some View {
        ScanView()
    }
}
