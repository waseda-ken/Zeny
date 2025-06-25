// RegisterView.swift
import SwiftUI

/// レシート登録用フォーム
struct RegisterView: View {
    @State private var storeName = ""
    @State private var purchaseDate = Date()
    @State private var totalAmountText = ""
    var onSave: ((PurchaseRecord) -> Void)?

    var body: some View {
        NavigationView {
            Form {
                Section("店舗名") {
                    TextField("例: コンビニA", text: $storeName)
                }
                Section("購入日") {
                    DatePicker("日付を選択", selection: $purchaseDate, displayedComponents: .date)
                }
                Section("合計金額") {
                    TextField("例: 1200", text: $totalAmountText)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("レシート登録")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") { saveRecord() }
                        .disabled(!isInputValid())
                }
            }
        }
    }

    private func isInputValid() -> Bool {
        !storeName.isEmpty && Double(totalAmountText) != nil
    }

    private func saveRecord() {
        guard let amt = Double(totalAmountText) else { return }
        let record = PurchaseRecord(storeName: storeName,
                                    purchaseDate: purchaseDate,
                                    totalAmount: amt)
        onSave?(record)
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView(onSave: { rec in print(rec) })
    }
}
