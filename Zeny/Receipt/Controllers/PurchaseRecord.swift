//
//  PurchaseRecord.swift
//  Zeny
//
//  Created by 永田健人 on 2025/06/25.
//

import Foundation
struct PurchaseRecord: Identifiable {
    let id = UUID()
    let storeName: String
    let purchaseDate: Date
    let totalAmount: Double
}
