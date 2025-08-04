// Zeny/Receipt/Models/PurchaseRecord.swift
import Foundation

/// ユーザーの購入レコード
struct PurchaseRecord: Identifiable {
    let id: UUID
    var storeName: String
    var purchaseDate: Date
    var totalAmount: Double
    var category: String          // ← 追加

    /// 全フィールドを受け取るイニシャライザ
    init(
        id: UUID = UUID(),
        storeName: String,
        purchaseDate: Date,
        totalAmount: Double,
        category: String
    ) {
        self.id           = id
        self.storeName    = storeName
        self.purchaseDate = purchaseDate
        self.totalAmount  = totalAmount
        self.category     = category
    }
}
