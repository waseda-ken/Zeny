import SwiftUI

struct ReceiptScannerViewControllerWrapper: UIViewControllerRepresentable {
    @Binding var recognizedText: String 

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> ReceiptScannerViewController {
        let vc = ReceiptScannerViewController()
        // VC 側のクロージャに SwiftUI の binding を渡す
        vc.onRecognized = { text in
            DispatchQueue.main.async {
                context.coordinator.parent.recognizedText = text
            }
        }
        return vc
    }
    func updateUIViewController(_ uiViewController: ReceiptScannerViewController, context: Context) {}

    class Coordinator: NSObject {
        var parent: ReceiptScannerViewControllerWrapper
        init(_ parent: ReceiptScannerViewControllerWrapper) { self.parent = parent }
    }
}
