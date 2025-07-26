//
//  ContentView.swift
//  Zeny
//
//  Created by 永田健人 on 2025/05/14.
//

import SwiftUI

struct CalendarScreenView: View {
    @State private var selectedDate = Date() // カレンダーで選択された日付
    
    // イベントデータを管理するEventManagerのインスタンス
    // @StateObject を使用することで、アプリのライフサイクルを通じてインスタンスが保持される
    @StateObject private var eventManager = EventManager()

    // 選択された日付に該当するイベントをフィルタリング
    private var eventsForSelectedDate: [Event] {
        eventManager.events.filter { event in // eventManager.events からフィルタリング
        Calendar.current.isDate(event.date, inSameDayAs: selectedDate)
        }
    }

    var body: some View {
        //NavigationView{
            VStack(spacing: 0) { // スペーシングを0にして要素間の余白をなくす
                CalendarControlView(selectedDate: $selectedDate, allEvents: $eventManager.events)
                // 高さをより多く確保するか、必要に応じてnilにして自動計算させる
                    .frame(height: 600) // 例: より高い固定値を指定
                    .aspectRatio(1.0, contentMode: .fit) // 幅に合わせて高さを調整 (正方形比率)
                // または、カレンダー全体を画面いっぱいに広げたい場合
                .frame(maxWidth: .infinity)
                
                DailyEventListView(events: .constant(eventsForSelectedDate))
                
                Spacer() // カレンダーを上部に押し上げる
                
                    //.padding()
            }
            //.navigationTitle("Zeny") // ナビゲーションタイトル
            //.navigationBarTitleDisplayMode(.inline) // タイトルの表示モード
        //}
    }
}

#Preview {
    CalendarScreenView()
}
