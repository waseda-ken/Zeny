// ZenyApp.swift
import SwiftUI

@main
struct ZenyApp: App {
    @StateObject private var eventManager = EventManager()

    init() {
        // ナビゲーションバーを薄いブラー＋透明背景に
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
                .environmentObject(eventManager)
        }
    }
}
