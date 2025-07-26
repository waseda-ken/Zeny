//
//  GraphControlView.swift
//  Zeny
//
//  Created by temp on 2025/07/26.
//

import SwiftUI
import Charts // Chartsフレームワークをインポート (念のため)

struct GraphControlView: View {
    @EnvironmentObject var eventManager: EventManager
    @State private var selectedMonthForPieChart: Date = Date() // 円グラフ用の月選択
    @State private var selectedYearForBarChart: Date = Date() // 棒グラフ用の年選択

    // MARK: - Date Formatters
    
    // 月と年を表示するためのフォーマッター
    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        return formatter
    }

    // 年のみを表示するためのフォーマッター
    private var yearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年"
        return formatter
    }

    var body: some View {
        VStack {
            // TabView を使用して、円グラフと棒グラフを横にスワイプで切り替える
            TabView {
                // 1つ目のグラフ：カテゴリごとの月単位円グラフ
                VStack {
                    // 現在の月を表示
                    Text(selectedMonthForPieChart, formatter: monthYearFormatter)
                        .font(.title2.bold())
                        .padding(.bottom) // グラフとの間にスペースを追加
                    
                    // 円グラフビュー
                    MonthlyCategoryPieChartView(selectedMonth: selectedMonthForPieChart)
                        // 月が変わったときにビューを再構築し、トランジションを有効にするためのID
                        .id(selectedMonthForPieChart)
                        // スライドトランジションとアニメーションを追加
                        .transition(.slide)
                        .animation(.easeInOut, value: selectedMonthForPieChart)
                }
                // このVStack全体にドラッグジェスチャーを追加
                .gesture(
                    DragGesture(minimumDistance: 10, coordinateSpace: .local) // 誤操作防止のため最小距離を設定
                        .onEnded { value in
                            // 垂直方向のドラッグを検出
                            if value.translation.height < 0 { // 上へスワイプ (Y値が減少) -> 次の月
                                if let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonthForPieChart) {
                                    selectedMonthForPieChart = nextMonth
                                }
                            } else if value.translation.height > 0 { // 下へスワイプ (Y値が増加) -> 前の月
                                if let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonthForPieChart) {
                                    selectedMonthForPieChart = previousMonth
                                }
                            }
                        }
                )
                .tabItem {
                    Label("カテゴリ別", systemImage: "chart.pie.fill")
                }

                // 2つ目のグラフ：月次収入・支出棒グラフ
                VStack {
                    // 現在の年を表示
                    Text(selectedYearForBarChart, formatter: yearFormatter)
                        .font(.title2.bold())
                        .padding(.bottom) // グラフとの間にスペースを追加

                    // 棒グラフビュー
                    YearlyMonthlyBarChartView(selectedYear: selectedYearForBarChart)
                        // 年が変わったときにビューを再構築し、トランジションを有効にするためのID
                        .id(selectedYearForBarChart)
                        // スライドトランジションとアニメーションを追加
                        .transition(.slide)
                        .animation(.easeInOut, value: selectedYearForBarChart)
                }
                // このVStack全体にドラッグジェスチャーを追加
                .gesture(
                    DragGesture(minimumDistance: 10, coordinateSpace: .local) // 誤操作防止のため最小距離を設定
                        .onEnded { value in
                            // 垂直方向のドラッグを検出
                            if value.translation.height < 0 { // 上へスワイプ (Y値が減少) -> 次の年
                                if let nextYear = Calendar.current.date(byAdding: .year, value: 1, to: selectedYearForBarChart) {
                                    selectedYearForBarChart = nextYear
                                }
                            } else if value.translation.height > 0 { // 下へスワイプ (Y値が増加) -> 前の年
                                if let previousYear = Calendar.current.date(byAdding: .year, value: -1, to: selectedYearForBarChart) {
                                    selectedYearForBarChart = previousYear
                                }
                            }
                        }
                )
                .tabItem {
                    Label("収支推移", systemImage: "chart.bar.fill")
                }
            }
            // TabViewのスタイル設定（ページングモードでインジケータを常に表示）
            .tabViewStyle(.page(indexDisplayMode: .always))
        }
    }
}

#Preview {
    GraphControlView()
        .environmentObject(EventManager()) // プレビュー用にEventManagerを渡す
}
