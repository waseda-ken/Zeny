import SwiftUI

struct ContentView: View {
    @State private var selectedTab: TabItem = .calendar

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
            CalendarView()
        case .graph:
            GraphView()
        case .scan:
            ScanView()
        case .manual:
            // onSave はダミーでも良いですが、実運用では ViewModel 呼び出しに変更してください
            ManualInputView(record: nil) { _ in }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
