//
//  ContentView.swift
//  Zeny
//
//  Created by 永田健人 on 2025/07/02.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: TabItem = .calendar

    var body: some View {
        ZStack {
            // タブに応じた画面切り替え
            Group {
                switch selectedTab {
                case .calendar: CalendarView()
                case .graph:    GraphView()
                case .scan:     ScanView()
                case .manual:   ManualInputView()
                }
            }
            .edgesIgnoringSafeArea(.all)

            // カスタムタブバーを画面下部に重ねる
            VStack {
                Spacer()
                CustomTabBar(selectedTab: $selectedTab)
            }
        }
    }
}

// プレビュー用
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
