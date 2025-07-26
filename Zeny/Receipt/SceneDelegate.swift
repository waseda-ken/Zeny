//
//  SceneDelegate.swift
//  Zeny
//
//  Created by 永田健人 on 2025/05/28.
//

// SceneDelegate.swift
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        // ここを UINavigationController で包む
        let rootVC = ReceiptScannerViewController()
        let nav = UINavigationController(rootViewController: rootVC)
        window.rootViewController = nav
        self.window = window
        window.makeKeyAndVisible()
    }}
