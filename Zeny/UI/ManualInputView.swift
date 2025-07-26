import SwiftUI

struct ManualInputView: View {
    @State private var amount: String
    @State private var selectedCategory: String
    @State private var storeName: String
    @State private var date: Date

    private let categories = ["収入","食費","固定費","日用費","娯楽費","交通費","医療費","その他"]
    let onSave: (PurchaseRecord) -> Void

    /// record があれば初期値、なければ空文字・今日の日付
    init(record: PurchaseRecord? = nil, onSave: @escaping (PurchaseRecord) -> Void) {
        _amount           = State(initialValue: record.map { String(format: "%.0f", $0.totalAmount) } ?? "")
        _storeName        = State(initialValue: record?.storeName ?? "")
        _date             = State(initialValue: record?.purchaseDate ?? Date())
        _selectedCategory = State(initialValue: "食費")  // デフォルト固定
        self.onSave       = onSave
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("金額")) {
                    TextField("¥0", text: $amount)
                        .keyboardType(.decimalPad)
                }
                Section(header: Text("カテゴリ")) {
                    Picker("カテゴリ", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { cat in
                            Text(cat)
                        }
                    }
                }
                Section(header: Text("店名")) {
                    TextField("例：コンビニ", text: $storeName)
                }
                Section(header: Text("日付")) {
                    DatePicker("日付を選択",
                               selection: $date,
                               displayedComponents: .date)
                }
                Section {
                    Button("登録する") {
                        saveEntry()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("レシート登録")
        }
    }

    private func saveEntry() {
        guard let amt = Double(amount) else { return }
        let record = PurchaseRecord(
            storeName:    storeName,
            purchaseDate: date,
            totalAmount:  amt
            // ← category はモデルにないので渡さない
        )
        onSave(record)
    }
}

struct ManualInputView_Previews: PreviewProvider {
    static var previews: some View {
        // ダミーデータでプレビュー
        let dummy = PurchaseRecord(storeName: "サンプル店",
                                   purchaseDate: Date(),
                                   totalAmount: 1234.0)
        ManualInputView(record: dummy) { rec in
            print("保存:", rec)
        }
    }
}
