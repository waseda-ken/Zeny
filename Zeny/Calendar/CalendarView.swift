//
//  CalendarView.swift
//  Zeny
//
//  Created by temp on 2025/05/28.
//

import SwiftUI
import FSCalendar
import UIKit
 
struct CalendarView: UIViewRepresentable {
    @Binding var selectedDate: Date
    // ContentViewからすべてのイベントを受け取るためのBinding
    @Binding var allEvents: [Event]
    
    func makeUIView(context: Context) -> UIView {
        
        typealias UIViewType = FSCalendar
        
        let fsCalendar = FSCalendar()
        
        fsCalendar.delegate = context.coordinator
        fsCalendar.dataSource = context.coordinator

        // Custom cell registration (CustomCalendarCellを使用する場合)
        fsCalendar.register(CustomCalendarCell.self, forCellReuseIdentifier: "cell")
                
        //表示
        fsCalendar.scrollDirection = .vertical //スクロールの方向
        fsCalendar.scope = .month //表示の単位（週単位 or 月単位）
        fsCalendar.locale = Locale(identifier: "ja") //表示の言語の設置（日本語表示の場合は"ja"）
        //ヘッダー
        fsCalendar.appearance.headerTitleFont = UIFont.systemFont(ofSize: 20) //ヘッダーテキストサイズ
        fsCalendar.appearance.headerDateFormat = "yyyy/MM" //ヘッダー表示のフォーマット
        fsCalendar.appearance.headerTitleColor = UIColor.label //ヘッダーテキストカラー
        fsCalendar.appearance.headerMinimumDissolvedAlpha = 0 //前月、翌月表示のアルファ量（0で非表示）
        //曜日表示
        fsCalendar.appearance.weekdayFont = UIFont.systemFont(ofSize: 20) //曜日表示のテキストサイズ
        fsCalendar.appearance.weekdayTextColor = .darkGray //曜日表示のテキストカラー
        fsCalendar.appearance.titleWeekendColor = .red //週末（土、日曜の日付表示カラー）
        // インデックス0が日曜日、インデックス6が土曜日です。
        if let weekdayLabels = fsCalendar.calendarWeekdayView.weekdayLabels as? [UILabel] {
                if weekdayLabels.count > 0 {
                    weekdayLabels[0].textColor = .red // 日曜日の曜日表示を赤に
                }
                if weekdayLabels.count > 6 {
                    weekdayLabels[6].textColor = .blue // 土曜日の曜日表示を青に
                }
            }
        
        //カレンダー日付表示
        fsCalendar.appearance.titleFont = UIFont.systemFont(ofSize: 16) //日付のテキストサイズ
        fsCalendar.appearance.titleFont = UIFont.systemFont(ofSize: 10, weight: UIFont.Weight.bold) //日付のテキスト、ウェイトサイズ
        fsCalendar.appearance.todayColor = .clear //本日の選択カラー
        fsCalendar.appearance.titleTodayColor = .orange //本日のテキストカラー
        
        fsCalendar.appearance.selectionColor = .clear //選択した日付のカラー
        //fsCalendar.appearance.borderSelectionColor = .black //選択した日付のボーダーカラー
        fsCalendar.appearance.titleSelectionColor = .green //選択した日付のテキストカラー
        
        //fsCalendar.appearance.borderRadius = 10 //本日・選択日の塗りつぶし角丸量
        // カスタムセルをFSCalendarに登録します
        fsCalendar.register(CustomCalendarCell.self, forCellReuseIdentifier: "customCell")
        return fsCalendar
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        guard let fsCalendar = uiView as? FSCalendar else { return }

               // FSCalendarの選択状態をselectedDateと同期
               // `select` メソッドは `scrollToDate` 引数なしで使用できます
               fsCalendar.select(selectedDate) // 修正箇所
               
               // allEventsの変更をカレンダーに反映させるためにリロード
               fsCalendar.reloadData() // 修正箇所
           }
    
    func makeCoordinator() -> Coordinator{
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
        var parent:CalendarView
        
        // 日付フォーマット（イベントデータ用）
        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone.current
            return formatter
        }()
        
        init(_ parent:CalendarView){
            self.parent = parent
        }
        // カスタムセルを返すデリゲートメソッド
        func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
            let cell = calendar.dequeueReusableCell(withIdentifier: "customCell", for: date, at: position)
            if let customCell = cell as? CustomCalendarCell {
                // その日付のイベントをフィルタリング
                let eventsForDate = parent.allEvents.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
                customCell.configure(with: eventsForDate)
            }
            return cell
        }
                
        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            parent.selectedDate = date
        }
        
        // イベントドットの色を返す
        func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
            
            let eventsForDate = parent.allEvents.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
            
            if eventsForDate.isEmpty {
                return nil
            }
            
            // Event.swiftで定義したcategoryUIColorを使用
            return eventsForDate.map { event in
                event.categoryUIColor // ここを修正
            }
        }
        
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
            let calendarCurrent = Calendar.current
                    
                // 現在カレンダーに表示されている月の年と月を取得
            let currentMonth = calendarCurrent.component(.month, from: calendar.currentPage)
            let currentYear = calendarCurrent.component(.year, from: calendar.currentPage)
                        
                // 現在処理している日付の年と月を取得
            let dateMonth = calendarCurrent.component(.month, from: date)
            let dateYear = calendarCurrent.component(.year, from: date)
                        
                // 日付が現在表示されている月に属するかどうかをチェック
            if dateMonth == currentMonth && dateYear == currentYear {
                let weekday = calendarCurrent.component(.weekday, from: date)
                if weekday == 1 { // 日曜日 (Calendar.current.component(.weekday, from: date)は日曜日を1、土曜日を7と返します)
                    return .red
                } else if weekday == 7 { // 土曜日
                    return .blue
                }
            }
            return nil // その他の曜日はデフォルトの色を使用
        }
    }
}
 
#Preview{
    VStack(spacing: 0) { // スペーシングを0にして要素間の余白をなくす
        // ★PreviewでもallEventsのBindingを渡す必要があります
        CalendarView(selectedDate: .constant(Date()), allEvents: .constant([
                Event(date: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 22))!, amount: 2500, category: "食費", storeName: "お寿司")
            ]))
                // 高さをより多く確保するか、必要に応じてnilにして自動計算させる
                .frame(height: 600) // 例: より高い固定値を指定
                .aspectRatio(1.0, contentMode: .fit) // 幅に合わせて高さを調整 (正方形比率)
                // または、カレンダー全体を画面いっぱいに広げたい場合
                //.frame(maxWidth: .infinity, maxHeight: .infinity)
            Spacer() // カレンダーを上部に押し上げる
        }
}
