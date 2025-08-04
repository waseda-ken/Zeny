// Zeny/Calendar/CalendarScreenView.swift
import SwiftUI

struct CalendarScreenView: View {
    @EnvironmentObject private var eventManager: EventManager
    @State private var selectedDate: Date = Date()
    
    // 選択日付に該当するイベント一覧
    private var eventsForDate: [Event] {
        eventManager.events.filter {
            Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // カレンダー本体
                CalendarControlView(
                    selectedDate: $selectedDate,
                    allEvents:    $eventManager.events
                )
                .frame(height: 400)
                .padding(.top)
                
                // 日別イベントリスト
                List {
                    if eventsForDate.isEmpty {
                        Text("この日に記録はありません")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(eventsForDate) { ev in
                            NavigationLink {
                                // 編集用画面に遷移
                                ManualInputView(record: PurchaseRecord(
                                    storeName:    ev.storeName,
                                    purchaseDate: ev.date,
                                    totalAmount:  Double(ev.amount),
                                    category:     ev.category
                                )) { newRec in
                                    // 更新された内容で Event を上書き
                                    let updated = Event(
                                        id:        ev.id,                      // 既存の ID をそのまま使う
                                        date:      newRec.purchaseDate,
                                        amount:    Int(newRec.totalAmount),
                                        category:  newRec.category,
                                        storeName: newRec.storeName
                                    )
                                    eventManager.updateEvent(updated)
                                }
                            } label: {
                                HStack {
                                    Text(ev.storeName)
                                    Spacer()
                                    Text("¥\(ev.amount)")
                                }
                                .padding(.vertical, 8)
                            }
                        }
                        .onDelete { offsets in
                            let ids = offsets.map { eventsForDate[$0].id }
                            eventManager.deleteEvents(for: ids)
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("カレンダー")
        }
    }
}

struct CalendarScreenView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarScreenView()
            .environmentObject(EventManager())
    }
}
