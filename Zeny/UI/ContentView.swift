import SwiftUI

struct ContentView: View {
    @State private var selectedTab: TabItem = .calendar
    // EventManagerのインスタンスを親ビューから受け取るように変更
        @EnvironmentObject var eventManager: EventManager 

    var body: some View {
        ZStack {
            content
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()
                CustomTabBar(selectedTab: $selectedTab)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch selectedTab {
        case .calendar:
            CalendarScreenView()
        case .graph:
            GraphScreenView()
        case .scan:
            ScanView()
        case .manual:
            // onSave クロージャ内で eventManager を使用してデータを追加
            ManualInputView(record: nil) { purchaseRecord in
                self.eventManager.addEvent(from: purchaseRecord)
                // 登録後に手入力画面を閉じるなど、追加の処理が必要であればここに記述
                self.selectedTab = .calendar // カレンダー画面に戻る
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
