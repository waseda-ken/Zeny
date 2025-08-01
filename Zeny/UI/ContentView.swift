// Zeny/UI/ContentView.swift
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var eventManager: EventManager
    @State private var selectedTab: TabItem = .calendar

    var body: some View {
        ZStack {
            switch selectedTab {
            case .calendar:
                NavigationStack {
                    CalendarScreenView()
                        .environmentObject(eventManager)
                }

            case .graph:
                NavigationStack {
                    GraphScreenView()
                        .environmentObject(eventManager)
                }

            case .scan:
                NavigationStack {
                    ScanView { rec in
                        eventManager.addEvent(from: rec)
                        selectedTab = .calendar
                    }
                    .environmentObject(eventManager)
                }

            case .manual:
                NavigationStack {
                    ManualInputView(onSave: { rec in
                        eventManager.addEvent(from: rec)
                        selectedTab = .calendar
                    })
                    .environmentObject(eventManager)
                }
            }

            VStack { Spacer() }
            // カスタムタブバーは変えず
            VStack {
                Spacer()
                CustomTabBar(selectedTab: $selectedTab)
            }
        }
    }
}
