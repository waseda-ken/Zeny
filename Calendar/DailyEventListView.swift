//
//  DailyEventListView.swift
//  Zeny
//
//  Created by temp on 2025/07/23.
//

import SwiftUI

struct DailyEventListView: View {
    @Binding var events: [Event] // 表示するイベントの配列
    let onDelete: (IndexSet) -> Void // 削除アクションを受け取るクロージャを追加

    var body: some View {
        if events.isEmpty {
            Text("この日はイベントがありません。")
                .foregroundColor(.gray)
                .padding()
        } else {
            List {
                // ★id: \.id を追加します
                ForEach(events, id: \.id) { event in
                    HStack {
                        // カテゴリドット (CalendarEventTableViewCell.swiftと同じ色ロジックを使用)
                        Circle()
                            .fill(event.categoryColor)
                            .frame(width: 8, height: 8)
                        
                        // 店名
                        Text(event.storeName)
                            .font(.headline)
                        
                        Spacer()
                        
                        // 金額とカテゴリ
                        VStack(alignment: .trailing) {
                            Text("¥\(event.amount)")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            Text(event.category)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete { indexSet in // イベント削除機能の追加
                    self.onDelete(indexSet) // 受け取ったonDeleteクロージャを呼び出す
                }
            }
            .listStyle(.plain) // リストのスタイルをシンプルに
        }
    }
}

#Preview {
    DailyEventListView(events: .constant([
        Event(date: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 22))!, amount: 2500, category: "食費", storeName: "寿司屋大将"),
        Event(date: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 22))!, amount: 500, category: "娯楽費", storeName: "映画館")
    ]),
    onDelete: { _ in }) // プレビュー用には空のクロージャを渡す
}
