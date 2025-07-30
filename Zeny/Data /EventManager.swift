//
//  EventManager.swift
//  Zeny
//
//  Created by temp on 2025/07/25.
//

import Foundation
import Combine // @Publishedを使用するため必要

// MARK: - EventManager クラス
class EventManager: ObservableObject {
    // @Published を付けることで、events配列が変更されたときにViewが自動的に更新される
    @Published var events: [Event] = [] {
        didSet {
            // events配列が変更されるたびにデータをUserDefaultsに保存
            saveEvents()
        }
    }

    private let userDefaultsKey = "allEvents" // UserDefaultsに保存するためのキー

    init() {
        // 初期化時に保存されたイベントデータを読み込む
        loadEvents()
    }

    // MARK: - データ操作メソッド

    // イベントを追加する
    func addEvent(_ event: Event) {
        events.append(event)
        // didSetが呼ばれて自動的に保存される
    }
    
    // PurchaseRecordからEventを作成して追加するメソッド
    func addEvent(from record: PurchaseRecord) {
        let newEvent = Event(date: record.purchaseDate, amount: Int(record.totalAmount), category: record.category, storeName: record.storeName)
        addEvent(newEvent)
    }

    // イベントを更新する (Optional: 必要であれば実装)
    func updateEvent(_ updatedEvent: Event) {
        if let index = events.firstIndex(where: { $0.id == updatedEvent.id }) {
            events[index] = updatedEvent
            // didSetが呼ばれて自動的に保存される
        }
    }

    // イベントを削除する
    func deleteEvents(at offsets: IndexSet) {
        events.remove(atOffsets: offsets)
        // didSetが呼ばれて自動的に保存される
    }
    
    // 特定のIDを持つイベントを削除する新しいメソッド
    func deleteEvents(for ids: [UUID]) {
        events.removeAll { event in
            ids.contains(event.id)
        }
    }

    // MARK: - 永続化メソッド

    // イベントデータをUserDefaultsに保存する
    private func saveEvents() {
        if let encoded = try? JSONEncoder().encode(events) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }

    // UserDefaultsからイベントデータを読み込む
    private func loadEvents() {
        if let savedEventsData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decodedEvents = try? JSONDecoder().decode([Event].self, from: savedEventsData) {
            self.events = decodedEvents
        } else {
            // 初回起動時やデータがない場合のサンプルデータ
            // ここに初期データを入れておくと、アプリ起動時にデータが空になりません
            self.events = [
                Event(date: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 2))!, amount: 1500, category: "食費", storeName: "とんかつ太郎"),
                Event(date: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 2))!, amount: 300, category: "娯楽費", storeName: "スターカフェ"),
                Event(date: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 2))!, amount: 500, category: "日用費", storeName: "コーヒー豆専門店"),
                Event(date: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 2))!, amount: 100, category: "交通費", storeName: "コンビニエンスストア"),
                Event(date: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 2))!, amount: 2500, category: "食費", storeName: "寿司屋大将"),
                Event(date: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 10))!, amount: 100000, category: "収入", storeName: "給与"),
                Event(date: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 15))!, amount: 50000, category: "固定費", storeName: "家賃"),
                Event(date: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 8))!, amount: 3000, category: "医療費", storeName: "〇〇病院"),
                Event(date: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 25))!, amount: 800, category: "その他", storeName: "郵便局"),
                Event(date: Calendar.current.date(from: DateComponents(year: 2024, month: 12, day: 25))!, amount: 1000, category: "その他", storeName: "郵便局"),
                Event(date: Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 23))!, amount: 70000, category: "食費", storeName: "コンビニ"),
                Event(date: Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 25))!, amount: 50000, category: "収入", storeName: "給与"),
            ]
        }
    }
}
