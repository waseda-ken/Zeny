//
//  ReceiptScannerViewControllerWrapper.swift
//  Zeny
//
//  Created by 永田健人 on 2025/06/11.
//

import SwiftUI

struct ReceiptScannerViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ReceiptScannerViewController {
        return ReceiptScannerViewController()
    }

    func updateUIViewController(_ uiViewController: ReceiptScannerViewController, context: Context) {}
}
