// PurchaseRecord.swift
import Foundation

/// 家計簿データモデル
struct PurchaseRecord: Identifiable {
    let id = UUID()
    let storeName: String
    let purchaseDate: Date
    let totalAmount: Double
}
