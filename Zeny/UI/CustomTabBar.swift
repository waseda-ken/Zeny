// UI/CustomTabBar.swift
import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: TabItem

    var body: some View {
        HStack {
            ForEach(TabItem.allCases, id: \.self) { item in
                Button(action: { selectedTab = item }) {
                    VStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color("AccentGold").opacity(selectedTab == item ? 1 : 0.3),
                                            Color("AccentGold").opacity(0)
                                        ]),
                                        startPoint: .top, endPoint: .bottom
                                    )
                                )
                                .frame(width: 36, height: 36)
                                .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 4)

                            Image(systemName: item.iconName)
                                .font(.title3)
                                .foregroundColor(selectedTab == item ? .white : .gray)
                        }
                        Text(item.title)
                            .font(.caption2)
                            .foregroundColor(selectedTab == item ? Color("AccentGold") : .gray)
                    }
                    .padding(.vertical, 6)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, 12)
        .background(
            BlurView(style: .systemUltraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .shadow(radius: 8)
        )
        .padding(.horizontal)
    }
}
