// UI/ScanView.swift
import SwiftUI

struct ScanView: View {
    @State private var showScanner = false
    @State private var recognizedText = ""      // ここに結果が入る
    @State private var parsedRecord: PurchaseRecord?

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Button("レシートをスキャン") {
                    showScanner = true
                }
                .sheet(isPresented: $showScanner) {
                    ReceiptScannerViewControllerWrapper(recognizedText: $recognizedText)
                }

                if !recognizedText.isEmpty {
                    Text("OCR結果:")
                    ScrollView {
                        Text(recognizedText)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }.frame(maxHeight: 200)

                    // 認識文字列を解析してPurchaseRecordに変換する処理を挟む
                    Button("登録画面へ進む") {
                        // 例：amountとdateとstoreNameを簡易パース
                        let amount = parseAmount(from: recognizedText)
                        let name   = parseStoreName(from: recognizedText)
                        self.parsedRecord = PurchaseRecord(
                            storeName: name,
                            purchaseDate: Date(),
                            totalAmount: amount
                        )
                    }
                    .disabled(parsedRecord != nil)
                    .padding(.top)

                    // parsedRecordができたらRegisterViewへ
                    if let rec = parsedRecord {
                        NavigationLink("詳細編集して保存", destination:
                            RegisterView(onSave: { saved in
                                // 保存処理…
                                print("保存されたレコード:", saved)
                            })
                            .onAppear {
                                // 初期値セットはRegisterView側にプロパティ追加で対応
                            }
                        )
                    }
                }

                Spacer()
            }
            .padding()
            .navigationTitle("スキャン")
        }
    }

    // シンプルパース例
    private func parseAmount(from text: String) -> Double {
        // 正規表現で数字だけ抜き出し etc
        Double(text.components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()) ?? 0
    }
    private func parseStoreName(from text: String) -> String {
        // 例として最初の行を店名とみなす
        text.components(separatedBy: "\n").first ?? ""
    }
}
