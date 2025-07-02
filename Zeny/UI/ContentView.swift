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
            Group {
                switch selectedTab {
                case .calendar: CalendarView()
                case .graph:    GraphView()
                case .scan:     ScanView()
                case .manual:   ManualInputView()
                }
            }
            .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()
                CustomTabBar(selectedTab: $selectedTab)
            }
        }
    }
}
