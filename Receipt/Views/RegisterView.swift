// Zeny/Receipt/Views/RegisterView.swift
import SwiftUI

struct RegisterView: View {
    // MARK: - State
    @State private var storeName: String
    @State private var purchaseDate: Date
    @State private var totalAmountText: String
    @State private var selectedCategory: String

    private let categories = [
        "収入","食費","固定費","日用費",
        "娯楽費","交通費","医療費","その他"
    ]

    let onSave: (PurchaseRecord) -> Void

    // MARK: - イニシャライザ
    init(record: PurchaseRecord, onSave: @escaping (PurchaseRecord) -> Void) {
        _storeName        = State(initialValue: record.storeName)
        _purchaseDate     = State(initialValue: record.purchaseDate)
        _totalAmountText  = State(initialValue: String(format: "%.0f", record.totalAmount))
        _selectedCategory = State(initialValue: record.category)
        self.onSave       = onSave
    }

    // MARK: - Body
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("金額")) {
                    TextField("¥0", text: $totalAmountText)
                        .keyboardType(.decimalPad)
                }

                Section(header: Text("カテゴリ")) {
                    Picker("カテゴリ", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section(header: Text("店名")) {
                    TextField("例：コンビニ", text: $storeName)
                }

                Section(header: Text("日付")) {
                    DatePicker("日付を選択", selection: $purchaseDate, displayedComponents: .date)
                }

                Section {
                    Button("保存") {
                        save()
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(totalAmountText.isEmpty)
                }
            }
            .navigationTitle("レシート編集")
        }
    }

    // MARK: - 保存処理
    private func save() {
        guard let amount = Double(totalAmountText) else { return }
        let updated = PurchaseRecord(
            storeName:    storeName,
            purchaseDate: purchaseDate,
            totalAmount:  amount,
            category:     selectedCategory
        )
        onSave(updated)
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        let sample = PurchaseRecord(
            storeName:    "サンプルコンビニ",
            purchaseDate: Date(),
            totalAmount:  450,
            category:     "食費"
        )
        RegisterView(record: sample) { rec in
            print("保存されたレコード:", rec)
        }
    }
}
