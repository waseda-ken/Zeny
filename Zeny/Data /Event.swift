//
//  Event.swift
//  Zeny
//
//  Created by temp on 2025/07/23.
//

import Foundation // Date型を使用するため必要
import SwiftUI // Color型を使用するため必要
import UIKit // UIColor型を使用するため必要

// MARK: - Event 構造体 (単一の定義)
struct Event: Identifiable, Hashable, Codable {
    let id = UUID()
    let date: Date
    let amount: Int // 金額
    let category: String // カテゴリ
    let storeName: String // 店名 (小文字 's' で統一)
    
    // カテゴリに応じたUIColorを返す算出プロパティ
    var categoryUIColor: UIColor {
        switch category {
        case "食費": return .systemGreen
        case "娯楽費": return .systemPurple
        case "交通費": return .systemTeal
        case "日用費": return .systemYellow
        case "固定費": return .systemRed
        case "医療費": return .systemBlue
        case "収入": return .systemOrange
        default: return .lightGray
        }
    }

    // カテゴリに応じたSwiftUI.Colorを返す算出プロパティ
    var categoryColor: Color {
        switch category {
        case "食費": return .green
        case "娯楽費": return .purple
        case "交通費": return .teal
        case "日用費": return .yellow
        case "固定費": return .red
        case "医療費": return .blue
        case "収入": return .orange
        default: return .gray
        }
    }
}
