// ReceiptScannerViewControllerWrapper.swift
import SwiftUI

struct ReceiptScannerViewControllerWrapper: UIViewControllerRepresentable {
    typealias UIViewControllerType = ReceiptScannerViewController

    func makeUIViewController(context: Context) -> ReceiptScannerViewController {
        ReceiptScannerViewController()
    }
    func updateUIViewController(_ uiViewController: ReceiptScannerViewController, context: Context) {}
}
