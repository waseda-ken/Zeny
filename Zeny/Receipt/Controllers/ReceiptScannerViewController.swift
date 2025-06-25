import UIKit
import Vision
import VisionKit
import PhotosUI

/// レシートスキャン＆OCR＋読み取り範囲指定付きビューコントローラ
final class ReceiptScannerViewController: UIViewController,
    VNDocumentCameraViewControllerDelegate,
    PHPickerViewControllerDelegate {

    /// タップした場所種別
    enum TapRegion { case topLeft, topRight, bottomLeft, bottomRight, center }

    // MARK: - UI Elements
    private var receiptImageView = UIImageView()
    private var regionView = UIView()
    private var scanButton = UIButton(type: .system)
    private var recognizeButton = UIButton(type: .system)
    private var resultTextView = UITextView()

    // MARK: - State
    private var tappedRegion: TapRegion? = nil
    private var hasPromptedImageSource = false

    // MARK: - Constants
    private let regionDefaultSize = CGSize(width: 200, height: 200)
    private let regionCenterSize = CGSize(width: 40, height: 40)
    private let regionMinSize = CGSize(width: 60, height: 60)

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

    // MARK: - Setup
    private func setupImageView() {
        receiptImageView.contentMode = .scaleAspectFit
        receiptImageView.translatesAutoresizingMaskIntoConstraints = false
        receiptImageView.isUserInteractionEnabled = true
        view.addSubview(receiptImageView)
        NSLayoutConstraint.activate([
            receiptImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            receiptImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            receiptImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            receiptImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4)
        ])
    }

    private func setupRegionView() {
        regionView.frame = CGRect(origin: .zero, size: regionDefaultSize)
        regionView.center = view.center
        regionView.backgroundColor = .clear
        regionView.layer.borderColor = UIColor.red.cgColor
        regionView.layer.borderWidth = 2
        regionView.isUserInteractionEnabled = true
        view.addSubview(regionView)
    }

    private func setupButtons() {
        scanButton.setTitle("スキャン/フォト選択", for: .normal)
        scanButton.translatesAutoresizingMaskIntoConstraints = false
        scanButton.addTarget(self, action: #selector(promptImageSource), for: .touchUpInside)
        view.addSubview(scanButton)

        recognizeButton.setTitle("OCR実行", for: .normal)
        recognizeButton.translatesAutoresizingMaskIntoConstraints = false
        recognizeButton.addTarget(self, action: #selector(cropAndRecognize), for: .touchUpInside)
        view.addSubview(recognizeButton)

        NSLayoutConstraint.activate([
            scanButton.topAnchor.constraint(equalTo: receiptImageView.bottomAnchor, constant: 12),
            scanButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            recognizeButton.topAnchor.constraint(equalTo: receiptImageView.bottomAnchor, constant: 12),
            recognizeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func setupResultView() {
        resultTextView.isEditable = false
        resultTextView.font = .systemFont(ofSize: 16)
        resultTextView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(resultTextView)
        NSLayoutConstraint.activate([
            resultTextView.topAnchor.constraint(equalTo: scanButton.bottomAnchor, constant: 12),
            resultTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            resultTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            resultTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

    // MARK: - Image Source
    @objc private func promptImageSource() {
        let ac = UIAlertController(title: "レシート画像取得", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "カメラでスキャン", style: .default) { _ in self.startCameraScan() })
        ac.addAction(UIAlertAction(title: "フォトライブラリ", style: .default) { _ in self.startPhotoPicker() })
        ac.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
        present(ac, animated: true)
    }

    private func startCameraScan() {
        guard VNDocumentCameraViewController.isSupported else { return }
        let cam = VNDocumentCameraViewController()
        cam.delegate = self
        present(cam, animated: true)
    }

    private func startPhotoPicker() {
        var cfg = PHPickerConfiguration()
        cfg.filter = .images
        cfg.selectionLimit = 1
        let picker = PHPickerViewController(configuration: cfg)
        picker.delegate = self
        present(picker, animated: true)
    }

    // MARK: - Delegates
    func documentCameraViewController(_ controller: VNDocumentCameraViewController,
                                      didFinishWith scan: VNDocumentCameraScan) {
        controller.dismiss(animated: true)
        receiptImageView.image = scan.imageOfPage(at: 0)
        regionView.center = view.center
    }
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let item = results.first?.itemProvider,
              item.canLoadObject(ofClass: UIImage.self) else { return }
        item.loadObject(ofClass: UIImage.self) { img, _ in
            DispatchQueue.main.async {
                self.receiptImageView.image = img as? UIImage
                self.regionView.center = self.view.center
            }
        }
    }

    // MARK: - Touch Handlers for Region Resize/Move
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let p = touches.first?.location(in: view), regionView.frame.contains(p) else { tappedRegion = nil; return }
        let lp = view.convert(p, to: regionView)
        let c = CGPoint(x: regionView.bounds.midX, y: regionView.bounds.midY)
        let centerRect = CGRect(x: c.x-regionCenterSize.width/2,
                                 y: c.y-regionCenterSize.height/2,
                                 width: regionCenterSize.width,
                                 height: regionCenterSize.height)
        if centerRect.contains(lp) { tappedRegion = .center }
        else if lp.x < c.x { tappedRegion = lp.y < c.y ? .topLeft : .bottomLeft }
        else { tappedRegion = lp.y < c.y ? .topRight : .bottomRight }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let p = touches.first?.location(in: view), let r = tappedRegion else { return }
        var f = regionView.frame
        switch r {
        case .topLeft:
            let dx = f.origin.x - p.x, dy = f.origin.y - p.y
            f.origin.x = p.x; f.origin.y = p.y; f.size.width += dx; f.size.height += dy
        case .topRight:
            let dy = f.origin.y - p.y
            f.origin.y = p.y; f.size.width = p.x - f.origin.x; f.size.height += dy
        case .bottomLeft:
            let dx = f.origin.x - p.x
            f.origin.x = p.x; f.size.width += dx; f.size.height = p.y - f.origin.y
        case .bottomRight:
            f.size.width = p.x - f.origin.x; f.size.height = p.y - f.origin.y
        case .center:
            regionView.center = p; return
        }
        f.size.width = max(f.size.width, regionMinSize.width)
        f.size.height = max(f.size.height, regionMinSize.height)
        regionView.frame = f
    }

    // MARK: - OCR Execution
    @objc private func cropAndRecognize() {
        guard let img = receiptImageView.image else { return }
        let cropRect = convertRect(regionView.frame, from: receiptImageView, to: img)
        guard let cg = img.cgImage?.cropping(to: cropRect) else { return }
        performOCR(on: UIImage(cgImage: cg))
    }

    private func performOCR(on image: UIImage) {
        resultTextView.text = "認識中…"
        guard let cg = image.cgImage else { return }
        let req = VNRecognizeTextRequest { [weak self] req, err in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let e = err {
                    self.resultTextView.text = "認識エラー: \(e.localizedDescription)"
                } else {
                    let lines = (req.results as? [VNRecognizedTextObservation])?.compactMap { $0.topCandidates(1).first?.string } ?? []
                    self.resultTextView.text = lines.joined(separator: "\n")
                }
            }
        }
        req.recognitionLevel = .accurate
        req.recognitionLanguages = ["ja-JP"]
        try? VNImageRequestHandler(cgImage: cg, options: [:]).perform([req])
    }

    // MARK: - Helper
    private func convertRect(_ rect: CGRect, from iv: UIImageView, to image: UIImage) -> CGRect {
        let ivs = iv.bounds.size, imgs = image.size
        let scale = min(ivs.width/imgs.width, ivs.height/imgs.height)
        let draw = CGSize(width: imgs.width*scale, height: imgs.height*scale)
        let xOff = (ivs.width - draw.width)/2, yOff = (ivs.height - draw.height)/2
        var r = rect
        r.origin.x = (r.origin.x - xOff)/scale; r.origin.y = (r.origin.y - yOff)/scale
        r.size.width /= scale; r.size.height /= scale
        return r
    }
}
