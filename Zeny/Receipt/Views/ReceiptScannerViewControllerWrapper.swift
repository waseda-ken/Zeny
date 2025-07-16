import SwiftUI

struct ReceiptScannerViewControllerWrapper: UIViewControllerRepresentable {
    @Binding var recognizedText: String

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> ReceiptScannerViewController {
        let vc = ReceiptScannerViewController()
        // OCR 結果を Binding に流し込む
        vc.onRecognized = { text in
            context.coordinator.parent.recognizedText = text
        }
        return vc
    }

    func updateUIViewController(_ uiViewController: ReceiptScannerViewController,
                                context: Context) {
        // no-op
    }

    class Coordinator {
        let parent: ReceiptScannerViewControllerWrapper
        init(_ parent: ReceiptScannerViewControllerWrapper) {
            self.parent = parent
        }
    }
}
