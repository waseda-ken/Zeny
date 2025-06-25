import UIKit
import Vision
import VisionKit
import PhotosUI

final class ReceiptScannerViewController: UIViewController,
    VNDocumentCameraViewControllerDelegate,
    PHPickerViewControllerDelegate {

    /// タップした場所の種別
    enum TapRegion { case topLeft, topRight, bottomLeft, bottomRight, center }

    // MARK: - UI Elements
    private var receiptImageView: UIImageView!
    private var regionView: UIView!
    private var recognizeButton: UIButton!
    private var resultTextView: UITextView!

    // 操作フラグ
    private var tappedRegion: TapRegion? = nil
    private var hasPromptedImageSource = false

    // 定数
    private let regionViewCenterRegion = CGSize(width: 40, height: 40)
    private let regionViewMinSize = CGSize(width: 60, height: 60)
    private let regionViewDefaultSize = CGSize(width: 200, height: 200)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "レシートOCR"
        view.backgroundColor = .systemBackground
        setupImageView()
        setupRegionView()
        setupButtons()
        setupResultView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !hasPromptedImageSource {
            hasPromptedImageSource = true
            promptImageSource()
        }
    }

    // MARK: - UI Setup
    private func setupImageView() {
        receiptImageView = UIImageView()
        receiptImageView.contentMode = .scaleAspectFit
        receiptImageView.translatesAutoresizingMaskIntoConstraints = false
        receiptImageView.isUserInteractionEnabled = true
        view.addSubview(receiptImageView)
        NSLayoutConstraint.activate([
            receiptImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            receiptImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            receiptImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            receiptImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5)
        ])
    }

    private func setupRegionView() {
        regionView = UIView(frame: CGRect(origin: .zero, size: regionViewDefaultSize))
        regionView.center = view.center
        regionView.backgroundColor = .clear
        regionView.layer.borderColor = UIColor.red.cgColor
        regionView.layer.borderWidth = 2
        regionView.isUserInteractionEnabled = true
        regionView.isMultipleTouchEnabled = true
        view.addSubview(regionView)
        // Pan for move
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        regionView.addGestureRecognizer(pan)
        // Pinch for scale
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        regionView.addGestureRecognizer(pinch)
    }

    private func setupButtons() {
        recognizeButton = UIButton(type: .system)
        recognizeButton.setTitle("範囲をOCR", for: .normal)
        recognizeButton.translatesAutoresizingMaskIntoConstraints = false
        recognizeButton.addTarget(self, action: #selector(cropAndRecognize), for: .touchUpInside)
        view.addSubview(recognizeButton)
        NSLayoutConstraint.activate([
            recognizeButton.topAnchor.constraint(equalTo: receiptImageView.bottomAnchor, constant: 16),
            recognizeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func setupResultView() {
        resultTextView = UITextView()
        resultTextView.isEditable = false
        resultTextView.font = .systemFont(ofSize: 16)
        resultTextView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(resultTextView)
        NSLayoutConstraint.activate([
            resultTextView.topAnchor.constraint(equalTo: recognizeButton.bottomAnchor, constant: 16),
            resultTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            resultTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            resultTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    // MARK: - Image Source Selection
    @objc private func promptImageSource() {
        let ac = UIAlertController(title: "レシート画像を取得", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "カメラでスキャン", style: .default) { _ in self.startCameraScan() })
        ac.addAction(UIAlertAction(title: "フォトライブラリ", style: .default) { _ in self.startPhotoPicker() })
        ac.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
        present(ac, animated: true)
    }

    private func startCameraScan() {
        guard VNDocumentCameraViewController.isSupported else { return }
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = self
        present(scanner, animated: true)
    }

    private func startPhotoPicker() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    // MARK: - Delegates
    func documentCameraViewController(_ controller: VNDocumentCameraViewController,
                                      didFinishWith scan: VNDocumentCameraScan) {
        controller.dismiss(animated: true)
        receiptImageView.image = scan.imageOfPage(at: 0)
        regionView.center = view.center
        regionView.transform = .identity
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let item = results.first?.itemProvider,
              item.canLoadObject(ofClass: UIImage.self) else { return }
        item.loadObject(ofClass: UIImage.self) { img, _ in
            DispatchQueue.main.async {
                self.receiptImageView.image = img as? UIImage
                self.regionView.center = self.view.center
                self.regionView.transform = .identity
            }
        }
    }

    // MARK: - Gesture Handlers
    @objc private func handlePan(_ g: UIPanGestureRecognizer) {
        let t = g.translation(in: view)
        if let v = g.view {
            v.center.x += t.x
            v.center.y += t.y
            g.setTranslation(.zero, in: view)
        }
    }

    @objc private func handlePinch(_ g: UIPinchGestureRecognizer) {
        if let v = g.view {
            v.bounds.size.width *= g.scale
            v.bounds.size.height *= g.scale
            g.scale = 1
        }
    }

    // MARK: - Touch Handling for Resize
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let p = touches.first?.location(in: view), regionView.frame.contains(p) else {
            tappedRegion = nil; return
        }
        let lp = view.convert(p, to: regionView)
        let c = CGPoint(x: regionView.bounds.midX, y: regionView.bounds.midY)
        let rectC = CGRect(x: c.x-regionViewCenterRegion.width/2,
                           y: c.y-regionViewCenterRegion.height/2,
                           width: regionViewCenterRegion.width,
                           height: regionViewCenterRegion.height)
        if rectC.contains(lp) { tappedRegion = .center }
        else if lp.x < c.x { tappedRegion = lp.y < c.y ? .topLeft : .bottomLeft }
        else { tappedRegion = lp.y < c.y ? .topRight : .bottomRight }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let p = touches.first?.location(in: view), let r = tappedRegion else { return }
        var f = regionView.frame
        switch r {
        case .topLeft:
            let dx = f.origin.x - p.x; let dy = f.origin.y - p.y
            f.origin.x = p.x; f.origin.y = p.y
            f.size.width += dx; f.size.height += dy
        case .topRight:
            let dy = f.origin.y - p.y
            f.origin.y = p.y
            f.size.width = p.x - f.origin.x
            f.size.height += dy
        case .bottomLeft:
            let dx = f.origin.x - p.x
            f.origin.x = p.x
            f.size.width += dx
            f.size.height = p.y - f.origin.y
        case .bottomRight:
            f.size.width = p.x - f.origin.x
            f.size.height = p.y - f.origin.y
        case .center:
            regionView.center = p; return
        }
        f.size.width = max(f.size.width, regionViewMinSize.width)
        f.size.height = max(f.size.height, regionViewMinSize.height)
        regionView.frame = f
    }

    // MARK: - Crop & OCR
    @objc private func cropAndRecognize() {
        guard let img = receiptImageView.image else { return }
        let cropRect = convertRect(regionView.frame, from: receiptImageView, to: img)
        guard let cg = img.cgImage?.cropping(to: cropRect) else { return }
        recognizeText(in: UIImage(cgImage: cg))
    }

    private func recognizeText(in image: UIImage) {
        resultTextView.text = "認識中…"
        guard let cg = image.cgImage else { return }
        let req = VNRecognizeTextRequest { req, err in
            DispatchQueue.main.async {
                if let e = err { self.resultTextView.text = "認識エラー: \(e.localizedDescription)" }
                else {
                    let lines = (req.results as? [VNRecognizedTextObservation])?.compactMap { $0.topCandidates(1).first?.string } ?? []
                    self.resultTextView.text = lines.joined(separator: "\n")
                }
            }
        }
        req.recognitionLevel = .accurate
        req.recognitionLanguages = ["ja-JP"]
        let handler = VNImageRequestHandler(cgImage: cg, options: [:])
        DispatchQueue.global(qos: .userInitiated).async { try? handler.perform([req]) }
    }

    // MARK: - Helpers
    private func convertRect(_ rect: CGRect, from iv: UIImageView, to image: UIImage) -> CGRect {
        let ivs = iv.bounds.size, imgs = image.size
        let scale = min(ivs.width/imgs.width, ivs.height/imgs.height)
        let draw = CGSize(width: imgs.width*scale, height: imgs.height*scale)
        let xoff = (ivs.width-draw.width)/2, yoff = (ivs.height-draw.height)/2
        var r = rect
        r.origin.x = (r.origin.x-xoff)/scale
        r.origin.y = (r.origin.y-yoff)/scale
        r.size.width /= scale; r.size.height /= scale
        return r
    }
}
