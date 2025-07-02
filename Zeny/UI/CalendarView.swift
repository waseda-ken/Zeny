//
//  CalendarView.swift
//  Zeny
//
//  Created by 永田健人 on 2025/07/02.
//

// UI/TabItem.swift
import SwiftUI

enum TabItem: String, CaseIterable {
    case calendar
    case graph
    case scan
    case manual

    // アイコン名
    var iconName: String {
        switch self {
        case .calendar:
            return "calendar"
        case .graph:
            return "chart.pie"
        case .scan:
            return "camera.viewfinder"
        case .manual:
            return "square.and.pencil"
        }
    }

    // タイトル文字列
    var title: String {
        switch self {
        case .calendar:
            return "カレンダー"
        case .graph:
            return "グラフ"
        case .scan:
            return "スキャン"
        case .manual:
            return "手入力"
        }
    }
}
