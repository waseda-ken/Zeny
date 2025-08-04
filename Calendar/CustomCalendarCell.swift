//
//  CustomCalendarCell.swift
//  Zeny
//
//  Created by temp on 2025/07/23.
//
import FSCalendar
import UIKit

class CustomCalendarCell: FSCalendarCell, UITableViewDataSource, UITableViewDelegate {
    
    // イベントを表示するためのUITableView
    var eventsTableView: UITableView!
    
    // このセルに表示するイベントのデータ
    var events: [Event] = [] {
        didSet {
            // events プロパティが設定されたらテーブルビューをリロード
            eventsTableView.reloadData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // MARK: - セルの境界線
        self.contentView.layer.borderWidth = 0.2
        self.contentView.layer.borderColor = UIColor.lightGray.cgColor
        self.contentView.layer.cornerRadius = 0.0
        self.contentView.layer.masksToBounds = true
        
        // MARK: - eventsTableViewの初期化と設定
        eventsTableView = UITableView(frame: .zero, style: .plain)
        eventsTableView.delegate = self
        eventsTableView.dataSource = self
        eventsTableView.isScrollEnabled = false // カレンダーセル内でスクロールさせない
        eventsTableView.separatorStyle = .none // セルの区切り線を表示しない
        eventsTableView.backgroundColor = .clear // 背景を透明に
        
        eventsTableView.isUserInteractionEnabled = false // UITableViewがタップイベントを横取りしないようにする
        
        // CalendarEventTableViewCell を登録 (存在すると仮定)
        eventsTableView.register(CalendarEventTableViewCell.self, forCellReuseIdentifier: "eventCell")
        
        self.contentView.addSubview(eventsTableView)
        
        // MARK: - 日付の数字のラベル (titleLabel) の位置調整
        // オートレイアウトを使用しないため、フレームを初期設定
        // 日付の数字が上部に表示されるようにスペースを確保
        self.titleLabel.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height * 0.4)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // MARK: - レイアウトの更新
        // 日付の数字のラベルのフレームを更新 (上部に固定)
        let titleLabelHeight: CGFloat = 10.0 // 日付の数字の高さ
        let titleLabelTopPadding: CGFloat = 5.0 // セル上部からのパディング
        
        self.titleLabel.frame = CGRect(x: 0,
                                       y: titleLabelTopPadding,
                                       width: self.bounds.width,
                                       height: titleLabelHeight)
        
        // eventsTableView のフレームを更新 (日付ラベルの下に配置し、残りのスペースを使用)
        let eventsTableViewY = titleLabelTopPadding + titleLabelHeight
        let eventsTableViewHeight = self.bounds.height - eventsTableViewY
        
        eventsTableView.frame = CGRect(x: 0, // 左右のパディングはUITableViewCell側で調整
                                       y: eventsTableViewY,
                                       width: self.bounds.width,
                                       height: eventsTableViewHeight)
    }
    
    // MARK: - configure メソッド
    // イベントデータをセルに設定するメソッド
    func configure(with events: [Event]) {
        self.events = events // didSet で tableView.reloadData() が呼ばれる
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! CalendarEventTableViewCell
        let event = events[indexPath.row]
        cell.configure(with: event)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // イベントセルの高さを固定値に設定
        return 15.0 // 例: 15ポイント
    }
    
    // セル選択時のハイライトを無効化
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
    }
}
