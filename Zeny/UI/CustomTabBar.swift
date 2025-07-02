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
                Button {
                    selectedTab = item
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: item.iconName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                        Text(item.title)
                            .font(.caption)
                    }
                    .foregroundColor(selectedTab == item ? .accentColor : .gray)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 6)
        .background(
            Color(UIColor.systemBackground)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(radius: 2)
        )
        .padding(.horizontal, 16)
    }
}
