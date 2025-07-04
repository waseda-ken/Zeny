// UI/ScanView.swift
import SwiftUI

struct ScanView: View {
    @State private var showScanner = false
    @State private var recognizedText = ""
    @State private var parsedRecord: PurchaseRecord?
    @State private var showRegister = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Button("レシートをスキャン") {
                    showScanner = true
                }
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(8)

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

                    Button("登録画面へ進む") {
                        // OCR結果をパースして PurchaseRecord にセット
                        let amount = parseAmount(from: recognizedText)
                        let name   = parseStoreName(from: recognizedText)
                        parsedRecord = PurchaseRecord(
                            storeName: name,
                            purchaseDate: Date(),
                            totalAmount: amount
                        )
                        showRegister = true     // フラグを立てる
                    }
                    .disabled(parsedRecord != nil)
                    .padding(.top)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("スキャン")
            .sheet(isPresented: $showScanner) {
                ReceiptScannerViewControllerWrapper(recognizedText: $recognizedText)
            }
            // iOS16+推奨 API
            .navigationDestination(isPresented: $showRegister) {
                // parsedRecord が nil の場合は EmptyView で安全に扱う
                if let record = parsedRecord {
                    RegisterView(record: record) { saved in
                        // 保存後の処理
                        print("保存されたレコード:", saved)
                    }
                } else {
                    EmptyView()
                }
            }
        }
    }

    private func parseAmount(from text: String) -> Double {
        let digits = text
            .components(separatedBy: CharacterSet(charactersIn: "0123456789.").inverted)
            .joined()
        return Double(digits) ?? 0
    }

    private func parseStoreName(from text: String) -> String {
        text.components(separatedBy: "\n").first ?? ""
    }
}

struct ScanView_Previews: PreviewProvider {
    static var previews: some View {
        ScanView()
    }
}
