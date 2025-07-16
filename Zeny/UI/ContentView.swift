// UI/ContentView.swift
import SwiftUI

struct ContentView: View {
    @State private var selectedTab: TabItem = .calendar

    var body: some View {
        TabView(selection: $selectedTab) {
            // ───────── カレンダータブ ─────────
            NavigationStack {
                CalendarView()
            }
            .tabItem {
                Image(systemName: TabItem.calendar.iconName)
                Text(TabItem.calendar.title)
            }
            .tag(TabItem.calendar)

            // ───────── グラフタブ ─────────
            NavigationStack {
                GraphView()
            }
            .tabItem {
                Image(systemName: TabItem.graph.iconName)
                Text(TabItem.graph.title)
            }
            .tag(TabItem.graph)

            // ───────── スキャンタブ ─────────
            NavigationStack {
                ScanView()
            }
            .tabItem {
                Image(systemName: TabItem.scan.iconName)
                Text(TabItem.scan.title)
            }
            .tag(TabItem.scan)

            // ───────── 手入力タブ ─────────
            NavigationStack {
                ManualInputView(onSave: { record in print("保存されたレコード:", record)})
            }
            .tabItem {
                Image(systemName: TabItem.manual.iconName)
                Text(TabItem.manual.title)
            }
            .tag(TabItem.manual)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
