//
//  ManualInputView.swift
//  Zeny
//
//  Created by 永田健人 on 2025/07/02.
//

import SwiftUI

struct ManualInputView: View {
    @State private var amount: String = ""
    @State private var selectedCategory: String = "食費"
    @State private var storeName: String = ""
    @State private var date: Date = Date()

    private let categories = ["収入","食費","固定費","日用費","娯楽費","交通費","医療費","その他"]

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
                    DatePicker("日付を選択", selection: $date, displayedComponents: .date)
                }
                Section {
                    Button(action: saveEntry) {
                        Text("登録する")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("手入力")
        }
    }

    private func saveEntry() {
        // エントリー保存ロジック（ViewModel等へ通知）
        print("保存: \(amount), \(selectedCategory), \(storeName), \(date)")
    }
}

struct ManualInputView_Previews: PreviewProvider {
    static var previews: some View {
        ManualInputView()
    }
}
