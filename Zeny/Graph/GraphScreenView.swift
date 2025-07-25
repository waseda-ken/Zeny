//
//  GraphScreenView.swift
//  Zeny
//
//  Created by temp on 2025/07/26.
//

import SwiftUI

struct GraphScreenView: View {
    @StateObject var eventManager = EventManager() // EventManagerのインスタンスを作成

    var body: some View {
        // EventManagerを環境オブジェクトとして注入
        GraphControlView()
            .environmentObject(eventManager)
    }
}

#Preview {
    GraphScreenView()
}
