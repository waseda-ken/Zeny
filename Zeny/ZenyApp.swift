import SwiftUI

@main
struct ZenyApp: App {
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance  = appearance
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .accentColor(Color("AccentGold"))
                .environment(\.colorScheme, .light)
        }
    }
}
