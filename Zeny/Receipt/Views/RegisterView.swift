import SwiftUI

// 家計簿登録用のSwiftUI View
struct RegisterView: View {
    // 受け渡し用データ
    @State var storeName: String = ""
    @State var purchaseDate: Date = Date()
    @State var totalAmount: String = ""

    // 保存完了時のコールバック
    var onSave: ((PurchaseRecord) -> Void)?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("店舗名")) {
                    TextField("例: コンビニA", text: $storeName)
                }
                Section(header: Text("購入日")) {
                    DatePicker("日付を選択", selection: $purchaseDate, displayedComponents: .date)
                }
                Section(header: Text("合計金額")) {
                    TextField("例: 1200", text: $totalAmount)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("レシート登録")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        // 入力チェック
                        guard let amount = Double(totalAmount) else { return }
                        let record = PurchaseRecord(storeName: storeName,
                                                    purchaseDate: purchaseDate,
                                                    totalAmount: amount)
                        onSave?(record)
                    }
                }
            }
        }
    }
}

// プレビュー用Mock
struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView() { record in
            print("保存: \(record)")
        }
    }
}
