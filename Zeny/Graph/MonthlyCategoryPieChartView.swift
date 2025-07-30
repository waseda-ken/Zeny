//
//  MonthlyCategoryPieChartView.swift
//  Zeny
//
//  Created by temp on 2025/07/26.
//

import SwiftUI
import Charts // Chartsフレームワークをインポート

struct MonthlyCategoryPieChartView: View {
    @EnvironmentObject var eventManager: EventManager
    let selectedMonth: Date // GraphViewから選択された月を受け取る

    var body: some View {
        let categorizedData = aggregateEventsByCategory(for: selectedMonth)

        if categorizedData.isEmpty {
            ContentUnavailableView {
                Label("データがありません", systemImage: "chart.pie")
            } description: {
                Text("選択された月にはイベントがありません。")
            }
        } else {
            Chart {
                ForEach(categorizedData, id: \.category) { data in
                    SectorMark(
                        angle: .value("Amount", data.amount),
                        innerRadius: 100, // ドーナツグラフにする場合
                        outerRadius: 150
                    )
                    .foregroundStyle(data.color) // ここを直接data.colorにする
                    .foregroundStyle(by: .value("カテゴリ", data.category)) // カテゴリの色を適用
                    /*.annotation(position: .overlay) {
                        Text(String(format: "￥%.0f", data.amount))
                            .font(.caption)
                            .foregroundStyle(.black)
                    }*/
                }
            }
            .chartBackground { chartProxy in
                GeometryReader { geometry in
                    let frame = geometry[chartProxy.plotFrame!]
                    VStack {
                        Text("合計金額")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(Int(categorizedData.map { $0.amount }.reduce(0, +)))円")
                            .font(.title2.bold())
                    }
                    .position(x: frame.midX, y: frame.midY)
                }
            }
            // ここから凡例のカスタマイズ
            .chartLegend { // 凡例のコンテンツを定義
                // 例えば、複数の列で表示するなど、より複雑なレイアウトを試す
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], alignment: .leading) {
                    ForEach(categorizedData, id: \.category) { data in
                        HStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(data.color)
                                .frame(width: 10, height: 10)
                            Text("\(data.category)：\(Int(data.amount))円")
                                .font(.system(size: 14)) // 例: サイズを14ポイントに
                                .foregroundStyle(.black) // 例: プライマリ色に
                            }
                        }
                }
                .padding(.vertical)
                .frame(height: 70) // ここにタブバーの高さに合わせたSpacerを追加
            }
            .padding()
            .navigationTitle("カテゴリ別月次円グラフ")
        }
    }

    // 月ごとのカテゴリ別合計金額を集計するヘルパー関数
    private func aggregateEventsByCategory(for date: Date) -> [CategorizedEventData] {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!

        let filteredEvents = eventManager.events.filter { event in
            return event.date >= startOfMonth && event.date <= endOfMonth
        }

        var aggregatedData: [String: Double] = [:]
        for event in filteredEvents {
            // 収入と支出を分けて集計するか、ここでは単純にすべて合算しています。
            // 収入をグラフに含めるか、含めないかは要件によります。
            // 例として、ここでは支出のみを対象とします。
            if event.category != "収入" {
                aggregatedData[event.category, default: 0] += Double(event.amount)
            }
        }

        return aggregatedData.map { (category, amount) in
            // Event構造体にあるcategoryColorプロパティを利用
            let event = eventManager.events.first { $0.category == category }
            return CategorizedEventData(category: category, amount: amount, color: event?.categoryColor ?? .gray)
        }.sorted { $0.amount > $1.amount } // 金額が多い順にソート
    }
}

// グラフ表示用のデータ構造
struct CategorizedEventData: Identifiable {
    let id = UUID()
    let category: String
    let amount: Double
    let color: Color
}

#Preview {
    MonthlyCategoryPieChartView(selectedMonth: Date())
        .environmentObject(EventManager())
}
