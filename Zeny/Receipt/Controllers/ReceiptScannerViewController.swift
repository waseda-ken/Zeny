import UIKit

final class ReceiptScannerViewController: UIViewController {

    /// タップした場所
    enum TapRegion {
        /// 左上
        case topLeft
        /// 右上
        case topRight
        /// 左下
        case bottomLeft
        /// 右下
        case bottomRight
        /// 中心
        case center
    }

    /// レシート画像
    var receiptImage: UIImage?

    /// 範囲指定用（赤枠のView）
    private var regionView: UIView!
    /// レシート画像表示用
    private var receiptImageView: UIImageView!
    /// regionViewのタップした場所
    private var tappedRegion: TapRegion? = nil

    /// tappedRegionでcenterと判定する範囲
    private let regionViewCenterRegion = CGSize(width: 40, height: 40)
    /// regionViewの幅と高さの最小値
    private let regionViewMinSize = CGSize(width: 60, height: 60)
    /// regionViewの初期表示のサイズ
    private let regionViewDefaultSize = CGSize(width: 200, height: 200)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        receiptImageView = UIImageView(image: receiptImage)
        view.addSubview(receiptImageView)
        receiptImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            receiptImageView.topAnchor.constraint(equalTo: view.topAnchor),
            receiptImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            receiptImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            receiptImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        regionView = UIView(frame: .init(origin: .zero, size: regionViewDefaultSize))
        view.addSubview(regionView)
        regionView.center = view.center
        regionView.backgroundColor = .clear
        regionView.layer.borderColor = UIColor.red.cgColor
        regionView.layer.borderWidth = 1
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: view),
              regionView.frame.contains(point) else {
            tappedRegion = nil
            return
        }

        let touchedPoint = view.convert(point, to: regionView)
        let center = CGPoint(x: regionView.frame.size.width/2, y: regionView.frame.size.height/2)
        if CGRect(x: center.x - regionViewCenterRegion.width/2, y: center.y - regionViewCenterRegion.height/2,
                  width: regionViewCenterRegion.width, height: regionViewCenterRegion.height).contains(touchedPoint) {
            tappedRegion = .center
        } else if touchedPoint.x < center.x {
            if touchedPoint.y < center.y {
                tappedRegion = .topLeft
            } else {
                tappedRegion = .bottomLeft
            }
        } else {
            if touchedPoint.y < center.y {
                tappedRegion = .topRight
            } else {
                tappedRegion = .bottomRight
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: view),
              let tappedRegion = tappedRegion else {
            return
        }

        var frame = regionView.frame
        switch tappedRegion {
        case .topLeft:
            frame.origin.x = point.x
            frame.origin.y = point.y
            frame.size.width += regionView.frame.origin.x - point.x
            frame.size.height += regionView.frame.origin.y - point.y
        case .topRight:
            frame.origin.y = point.y
            frame.size.width = point.x - regionView.frame.origin.x
            frame.size.height += regionView.frame.origin.y - point.y
        case .bottomLeft:
            frame.origin.x = point.x
            frame.size.width += regionView.frame.origin.x - point.x
            frame.size.height = point.y - regionView.frame.origin.y
        case .bottomRight:
            frame.size.width = point.x - regionView.frame.origin.x
            frame.size.height = point.y - regionView.frame.origin.y
        case .center:
            regionView.center = point
            return
        }

        if frame.size.width < regionViewMinSize.width {
            frame.size.width = regionViewMinSize.width
        }
        if frame.size.height < regionViewMinSize.height {
            frame.size.height = regionViewMinSize.height
        }
        regionView.frame = frame
    }
}
