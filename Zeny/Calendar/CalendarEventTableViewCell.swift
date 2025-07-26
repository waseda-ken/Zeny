//
//  CalendarEventTableViewCell.swift
//  Zeny
//
//  Created by temp on 2025/07/23.
//
import UIKit

class CalendarEventTableViewCell: UITableViewCell {
    let eventTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 9) // イベント表示用のフォントサイズ
        label.textColor = .darkText
        label.numberOfLines = 1 // 1行表示
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false // オートレイアウトを使用
        return label
    }()

    // イベントのドット表示用のビュー
    let eventDotView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGreen // ドットの色
        view.layer.cornerRadius = 3 // ドットの丸み
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.contentView.addSubview(eventDotView)
        self.contentView.addSubview(eventTitleLabel)
        self.selectionStyle = .none // セル選択時のハイライトを無効化
        self.backgroundColor = .clear // 背景を透明に
        
        // MARK: - イベントセルに枠線を追加
        self.contentView.layer.borderWidth = 0.5 // 枠線の太さ
        self.contentView.layer.borderColor = UIColor.black.cgColor // 枠線の色
        self.contentView.layer.cornerRadius = 3.0 // 枠線の角丸
        self.contentView.layer.masksToBounds = true // 角丸を適用するために必要

        NSLayoutConstraint.activate([
            eventDotView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            eventDotView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            eventDotView.widthAnchor.constraint(equalToConstant: 6),
            eventDotView.heightAnchor.constraint(equalToConstant: 6),

            eventTitleLabel.leadingAnchor.constraint(equalTo: eventDotView.trailingAnchor, constant: 4), // ドットの右に配置
            eventTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2),
            eventTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 1),
            eventTitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -1)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with event: Event) {
        eventTitleLabel.text = event.storeName
        
        // カテゴリに基づいてドットの色を設定
        eventDotView.backgroundColor = event.categoryUIColor
    }
}
