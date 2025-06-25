// RegisterView.swift
import SwiftUI

/// レシート登録用の SwiftUI View
struct RegisterView: View {
    // MARK: - 入力フィールド
    @State private var storeName: String = ""
    @State private var purchaseDate: Date = Date()
    @State private var totalAmountText: String = ""

    /// 保存完了時のコールバック
    var onSave: ((PurchaseRecord) -> Void)? = nil

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("店舗名")) {
                    TextField("例: コンビニA", text: $storeName)
                        .autocapitalization(.words)
                }
                Section(header: Text("購入日")) {
                    DatePicker("日付を選択", selection: $purchaseDate, displayedComponents: .date)
                }
                Section(header: Text("合計金額")) {
                    TextField("例: 1200", text: $totalAmountText)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("レシート登録")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveRecord()
                    }
                    .disabled(!isInputValid())
                }
            }
        }
    }

    private func isInputValid() -> Bool {
        !storeName.isEmpty && Double(totalAmountText) != nil
    }

    private func saveRecord() {
        guard let amount = Double(totalAmountText) else { return }
        let record = PurchaseRecord(
            storeName: storeName,
            purchaseDate: purchaseDate,
            totalAmount: amount
        )
        onSave?(record)
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView(onSave: { record in
            print("保存: \(record)")
        })
    }
}
