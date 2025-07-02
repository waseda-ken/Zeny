//
//  TabItem.swift
//  Zeny
//
//  Created by 永田健人 on 2025/07/02.
//

// UI/TabItem.swift
import SwiftUI

enum TabItem: String, CaseIterable {
    case calendar, graph, scan, manual
    var iconName: String { /* … */ }
    var title: String    { /* … */ }
}
