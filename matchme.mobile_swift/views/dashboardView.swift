//
//  dashboardView.swift
//  matchme.mobile_swift
//
//  Created by Gideon Adewuyi on 29/08/2024.
//

import SwiftUI
import SwiftfulRouting

struct DashboardView: View {
    @State var currentPage = 3

    var body: some View {
        TabView(selection: $currentPage) {
            ExploreView()
                .tabItem {
                    CuddleTabItem(
                        activeImage: "explore_active",
                        inactiveImage: "explore_inactive",
                        label: "Explore",
                        tag: 0,
                        selection: $currentPage
                    )
                }.tag(0)

            LikeView()
                .tabItem {
                    CuddleTabItem(
                        activeImage: "likes_active",
                        inactiveImage: "likes_inactive",
                        label: "Likes",
                        tag: 1,
                        selection: $currentPage
                    )
                }.tag(1)

            ChatView()
                .tabItem {
                    CuddleTabItem(
                        activeImage: "message_active",
                        inactiveImage: "message_inactive",
                        label: "Chats",
                        tag: 2,
                        selection: $currentPage
                    )
                }.tag(2)

            ProfileView()
                .tabItem {
                    CuddleTabItem(
                        activeImage: "user_active",
                        inactiveImage: "user_inactive",
                        label: "Profile",
                        tag: 3,
                        selection: $currentPage
                    )
                }.tag(3)
        }
        .tint(.black)
    }
}

// ISS-042: Drive isActive from the TabView selection binding directly
// so the label re-evaluates whenever the user switches tabs.
struct CuddleTabItem: View {
    let activeImage: String
    let inactiveImage: String
    let label: String
    let tag: Int
    @Binding var selection: Int

    private var isActive: Bool { selection == tag }

    var body: some View {
        VStack {
            Image(isActive ? activeImage : inactiveImage)
            Text(label)
                .cuddleFont(size: 10, weight: isActive ? .medium : .regular)
                .foregroundStyle(isActive ? .primary : .greyABAD)
        }
    }
}

#Preview {
		DashboardView()
}
