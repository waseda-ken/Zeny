//
//  YearlyMonthlyBarChartView.swift
//  Zeny
//
//  Created by temp on 2025/07/26.
//

import SwiftUI
import Charts

// 棒グラフのシリーズタイプを定義
enum SeriesType: String, Plottable {
    case income = "収入"
    case expense = "支出"
}

struct YearlyMonthlyBarChartView: View {
    @EnvironmentObject var eventManager: EventManager
    let selectedYear: Date // GraphViewから選択された年を受け取る
    
    @State private var selectedMonthData: MonthlySummary? = nil // タップされた月のデータを保持

    var body: some View {
        let monthlyData = aggregateMonthlyData(for: selectedYear)

        VStack {
            if monthlyData.isEmpty {
                ContentUnavailableView {
                    Label("データがありません", systemImage: "chart.bar")
                } description: {
                    Text("選択された年にはイベントがありません。")
                }
            } else {
                // グラフ部分を別のプロパティに切り出す
                barChart(monthlyData: monthlyData)
                    // SpatialTapGesture を使用して、タップ位置情報を取得
                    .chartGesture { proxy in
                        SpatialTapGesture()
                            .onEnded { value in
                                // value.location にタップされた位置情報 (CGPoint) が含まれる
                                let location = value.location
                                
                                // ChartProxy を使用して、タップされたX座標に対応するDate値を取得
                                if let date: Date = proxy.value(atX: location.x) {
                                    let calendar = Calendar.current
                                    let tappedMonth = calendar.dateComponents([.year, .month], from: date)
                                    
                                    selectedMonthData = monthlyData.first {
                                        let dataMonth = calendar.dateComponents([.year, .month], from: $0.month)
                                        return dataMonth.year == tappedMonth.year && dataMonth.month == tappedMonth.month
                                    }
                                }
                            }
                    }
                    .padding()
                    .navigationTitle("月次収入・支出棒グラフ")

                // タップされた月の詳細表示
                if let data = selectedMonthData {
                    VStack(alignment: .leading) {
                        Text("\(data.month, formatter: monthFormatter)")
                            .font(.headline)
                        Text("収入: \(Int(data.income))円")
                        Text("支出: \(Int(data.expense))円")
                        Text("差額: \(Int(data.income - data.expense))円")
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                    .padding(.horizontal)
                } else {
                    Text("グラフをタップして詳細を表示")
                        .padding()
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Helper Views
    
    // 棒グラフ本体を生成するヘルパープロパティ
    private func barChart(monthlyData: [MonthlySummary]) -> some View {
        Chart {
            ForEach(monthlyData, id: \.month) { data in
                // 収入の棒グラフ
                BarMark(
                    x: .value("月", data.month, unit: .month),
                    y: .value("収入", data.income)
                )
                .foregroundStyle(Color.red) // 収入の色
                // position(by:)を使用して、シリーズタイプでグループ化
                // PlottableValue.value を使用して、グラフ上で並べるためのキーと値を指定
                .position(by: .value("Type", SeriesType.income))
                .annotation(position: .top, alignment: .bottom) { // iOS 17+
                    if data.income > 0 {
                        Text("\(Int(data.income))")
                            .font(.caption2)
                            .foregroundStyle(.primary)
                    }
                }
                
                // 支出の棒グラフ
                BarMark(
                    x: .value("月", data.month, unit: .month),
                    y: .value("支出", data.expense)
                )
                .foregroundStyle(Color.blue) // 支出の色
                // position(by:)を使用して、シリーズタイプでグループ化
                .position(by: .value("Type", SeriesType.expense))
                .annotation(position: .top, alignment: .bottom) { // iOS 17+
                    if data.expense > 0 {
                        Text("\(Int(data.expense))")
                            .font(.caption2)
                            .foregroundStyle(.primary)
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .month)) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.month(.narrow)) // 月の略称を表示
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) // Y軸を左側に表示
        }
        .chartLegend(.hidden) // 凡例を非表示にする（必要に応じて表示しても良い）
    }

    // MARK: - Data Aggregation

    // 年ごとの月次収入・支出を集計するヘルパー関数
    private func aggregateMonthlyData(for date: Date) -> [MonthlySummary] {
        let calendar = Calendar.current
        let selectedYearComponent = calendar.dateComponents([.year], from: date).year!

        var monthlySummaries: [Date: (income: Double, expense: Double)] = [:]

        // 1月から12月までの各月のDateオブジェクトを初期化
        // これを事前に全月分行うことで、データがない月も0で表示されるようにする
        for monthIndex in 1...12 {
            if let monthDate = calendar.date(from: DateComponents(year: selectedYearComponent, month: monthIndex, day: 1)) {
                monthlySummaries[monthDate] = (income: 0, expense: 0)
            }
        }

        for event in eventManager.events {
            let eventYearComponent = calendar.dateComponents([.year], from: event.date).year!
            
            if eventYearComponent == selectedYearComponent {
                // 月の初日のDateオブジェクトを取得
                if let monthDate = calendar.date(from: calendar.dateComponents([.year, .month], from: event.date)) {
                    if event.category == "収入" {
                        monthlySummaries[monthDate, default: (income: 0, expense: 0)].income += Double(event.amount)
                    } else {
                        monthlySummaries[monthDate, default: (income: 0, expense: 0)].expense += Double(event.amount)
                    }
                }
            }
        }

        return monthlySummaries.map { (month, data) in
            MonthlySummary(month: month, income: data.income, expense: data.expense)
        }.sorted { $0.month < $1.month } // 月が古い順にソート
    }
    
    // 月を表示するためのフォーマッター
    private var monthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        return formatter
    }
}

// 月ごとの集計データ構造
struct MonthlySummary: Identifiable {
    let id = UUID()
    let month: Date
    let income: Double
    let expense: Double
}

#Preview {
    YearlyMonthlyBarChartView(selectedYear: Date())
        .environmentObject(EventManager()) // プレビュー用にEventManagerを渡す
}
