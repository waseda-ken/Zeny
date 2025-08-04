//
//  GraphControlView.swift
//  Zeny
//
//  Created by temp on 2025/07/26.
//

import SwiftUI
import Charts // Chartsフレームワークをインポート (念のため)

struct GraphControlView: View {
    // 現在選択されているタブのインデックスを保持するState変数
    @State private var selectedTab: Int = 0 // ここを追加
    
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
            // カスタムインジケーターの例 (簡単な例であり、選択状態の同期ロジックは別途必要)
            HStack(spacing: 0) {
                // 最初のタブ（月別カテゴリ円グラフ）のインジケーター
                Text("カテゴリ別支出") // 表示したい説明文字
                    .font(.system(size: 16)) // 例: サイズを14ポイントに
                    //.foregroundStyle(.black) // 例: プライマリ色に
                    .fontWeight(selectedTab == 0 ? .bold : .regular) // 選択されていれば太字
                    .foregroundColor(selectedTab == 0 ? .blue : .black) // 選択されていれば青、そうでなければ灰色
                    .padding(.horizontal, 40) // テキストの左右にパディング
                    .padding(.vertical, 5) // テキストの上下にパディング
                    .background(selectedTab == 0 ? Color.blue.opacity(0.2) : Color.clear) // 選択されていれば背景色を薄く表示
                    .cornerRadius(5) // 角を丸くする
                    .onTapGesture { // タップでタブを切り替えられるようにする
                        selectedTab = 0
                    }
                                
                // 2番目のタブ（年別月別棒グラフ）のインジケーター
                Text("月別収支推移") // 表示したい説明文字
                    .font(.system(size: 16)) // 例: サイズを14ポイントに
                    //.foregroundStyle(.black) // 例: プライマリ色に
                    .fontWeight(selectedTab == 1 ? .bold : .regular) // 選択されていれば太字
                    .foregroundColor(selectedTab == 1 ? .blue : .black) // 選択されていれば青、そうでなければ灰色
                    .padding(.horizontal, 40)
                    .padding(.vertical, 5)
                    .background(selectedTab == 1 ? Color.blue.opacity(0.2) : Color.clear)
                    .cornerRadius(5)
                    .onTapGesture {
                        selectedTab = 1
                    }
            }
            .padding(.bottom, 40) // 必要に応じてパディングを調整
            
            // TabView を使用して、円グラフと棒グラフを横にスワイプで切り替える
            TabView (selection: $selectedTab) {
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
                .tag(0)

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
                .tag(1)
            }
            // TabViewのスタイル設定（ページングモードでインジケータを常に表示）
            .tabViewStyle(.page(indexDisplayMode: .never))
            .padding(.bottom, 20) // 必要に応じてパディングを調整
        }
    }
}

#Preview {
    GraphControlView()
        .environmentObject(EventManager()) // プレビュー用にEventManagerを渡す
}
