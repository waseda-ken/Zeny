//
//  CustomTabBar.swift
//  Zeny
//
//  Created by 永田健人 on 2025/07/02.
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: TabItem

    var body: some View {
        HStack {
            ForEach(TabItem.allCases, id: \.self) { item in
                if item == .scan {
                    Spacer()
                    ZStack {
                        Circle()/* … 背景 */
                        Button { selectedTab = .scan } label: {
                            Image(systemName: item.iconName)/* … */
                        }
                    }
                    .offset(y: -24)
                    Spacer()
                } else {
                    Button { selectedTab = item } label: {
                        VStack { Image(systemName: item.iconName); Text(item.title) }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(/* … */)
        .background(/* … */)
        .padding(.horizontal, 16)
    }
}

