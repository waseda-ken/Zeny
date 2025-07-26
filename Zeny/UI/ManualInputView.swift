// UI/ManualInputView.swift
import SwiftUI

struct ManualInputView: View {
    enum Field { case amount, storeName }

    @State private var amount: String
    @State private var selectedCategory: String
    @State private var storeName: String
    @State private var date: Date

    @FocusState private var focusedField: Field?

    private let categories = [
        "収入","食費","固定費","日用費",
        "娯楽費","交通費","医療費","その他"
    ]
    let onSave: (PurchaseRecord) -> Void

    init(record: PurchaseRecord? = nil, onSave: @escaping (PurchaseRecord) -> Void) {
        _amount           = State(initialValue: record.map { String(format: "%.0f", $0.totalAmount) } ?? "")
        _selectedCategory = State(initialValue: record?.category ?? "食費")
        _storeName        = State(initialValue: record?.storeName   ?? "")
        _date             = State(initialValue: record?.purchaseDate ?? Date())
        self.onSave       = onSave
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("金額")) {
                    TextField("¥0", text: $amount)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .amount)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(
                                    focusedField == .amount
                                        ? Color.accentColor.opacity(0.8)
                                        : Color(UIColor.separator),
                                    lineWidth: focusedField == .amount ? 2 : 1
                                )
                                .animation(
                                    .easeInOut(duration: 0.8)
                                        .repeatForever(autoreverses: true),
                                    value: focusedField
                                )
                        )
                }

                Section(header: Text("カテゴリ")) {
                    Picker(selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { Text($0) }
                    } label: {
                        HStack {
                            Text(selectedCategory)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding(8)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                    }
                    .frame(maxWidth: .infinity)
                }

                Section(header: Text("店名")) {
                    TextField("例：コンビニ", text: $storeName)
                        .focused($focusedField, equals: .storeName)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(
                                    focusedField == .storeName
                                        ? Color.accentColor.opacity(0.8)
                                        : Color(UIColor.separator),
                                    lineWidth: focusedField == .storeName ? 2 : 1
                                )
                                .animation(
                                    .easeInOut(duration: 0.8)
                                        .repeatForever(autoreverses: true),
                                    value: focusedField
                                )
                        )
                }

                Section(header: Text("日付")) {
                    DatePicker("日付を選択", selection: $date, displayedComponents: .date)
                }

                Section {
                    Button("登録する") {
                        saveEntry()
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(amount.isEmpty)
                }
            }
            .navigationTitle("手入力")
            .onAppear { focusedField = .amount }
        }
    }

    private func saveEntry() {
        guard let amt = Double(amount) else { return }
        let rec = PurchaseRecord(
            storeName:    storeName,
            purchaseDate: date,
            totalAmount:  amt,
            category:     selectedCategory
        )
        onSave(rec)
    }
}

struct ManualInputView_Previews: PreviewProvider {
    static var previews: some View {
        let dummy = PurchaseRecord(
            storeName:    "サンプル店",
            purchaseDate: Date(),
            totalAmount:  1200,
            category:     "日用費"
        )
        ManualInputView(record: dummy) { rec in
            print("保存:", rec)
        }
    }
}
