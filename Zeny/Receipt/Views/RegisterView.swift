// UI/RegisterView.swift
import SwiftUI

struct RegisterView: View {
    @State private var storeName: String
    @State private var purchaseDate: Date
    @State private var totalAmountText: String

    let onSave: (PurchaseRecord) -> Void

    init(record: PurchaseRecord, onSave: @escaping (PurchaseRecord) -> Void) {
        _storeName       = State(initialValue: record.storeName)
        _purchaseDate    = State(initialValue: record.purchaseDate)
        _totalAmountText = State(initialValue: String(format: "%.2f", record.totalAmount))
        self.onSave      = onSave
    }

    var body: some View {
        Form {
            Section("店舗名") {
                TextField("例: コンビニA", text: $storeName)
            }
            Section("日付") {
                DatePicker("", selection: $purchaseDate, displayedComponents: .date)
            }
            Section("合計金額") {
                TextField("¥0", text: $totalAmountText)
                    .keyboardType(.decimalPad)
            }
            Section {
                Button("保存する") { saveRecord() }
                    .frame(maxWidth: .infinity)
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
        let dummy = PurchaseRecord(storeName: "サンプル店", purchaseDate: Date(), totalAmount: 1234.56)
        RegisterView(record: dummy) { _ in }
    }
}
