// UI/RegisterView.swift
import SwiftUI

/// レシート登録用フォーム
struct RegisterView: View {
    // 初期値は外部から渡す
    @State private var storeName: String
    @State private var purchaseDate: Date
    @State private var totalAmountText: String

    let onSave: (PurchaseRecord) -> Void

    /// レコードを受け取って初期値をセットするイニシャライザ
    init(record: PurchaseRecord, onSave: @escaping (PurchaseRecord) -> Void) {
        _storeName       = State(initialValue: record.storeName)
        _purchaseDate    = State(initialValue: record.purchaseDate)
        _totalAmountText = State(initialValue: String(format: "%.2f", record.totalAmount))
        self.onSave      = onSave
    }

    var body: some View {
        Form {
            Section(header: Text("店舗名")) {
                TextField("例: コンビニA", text: $storeName)
            }
            Section(header: Text("日付")) {
                DatePicker("日付を選択", selection: $purchaseDate, displayedComponents: .date)
            }
            Section(header: Text("合計金額")) {
                TextField("¥0", text: $totalAmountText)
                    .keyboardType(.decimalPad)
            }
            Section {
                Button(action: saveRecord) {
                    Text("保存する")
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .navigationTitle("レシート登録")
    }

    private func saveRecord() {
        guard let amt = Double(totalAmountText) else { return }
        let record = PurchaseRecord(
            storeName: storeName,
            purchaseDate: purchaseDate,
            totalAmount: amt
        )
        onSave(record)
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        // ダミーデータを渡してプレビュー
        let dummy = PurchaseRecord(storeName: "サンプル店", purchaseDate: Date(), totalAmount: 1234.56)
        RegisterView(record: dummy) { rec in
            print("プレビュー保存:", rec)
        }
    }
}
