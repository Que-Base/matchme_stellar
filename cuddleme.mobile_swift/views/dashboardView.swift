//
//  dashboardView.swift
//  cuddleme.mobile_swift
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
												isActive: currentPage == 0
										)
								}.tag(0)

						LikeView()
								.tabItem {
										CuddleTabItem(
												activeImage: "likes_active",
												inactiveImage: "likes_inactive",
												label: "Likes",
												isActive: currentPage == 1
										)

								}.tag(1)

						ChatView()
								.tabItem {
										CuddleTabItem(
												activeImage: "message_active",
												inactiveImage: "message_inactive",
												label: "Chats",
												isActive: currentPage == 2
										)
								}.tag(2)

						ProfileView()
								.tabItem {
										CuddleTabItem(
												activeImage: "user_active",
												inactiveImage: "user_inactive",
												label: "Profile",
												isActive: currentPage == 3
										)
								}.tag(3)
				}
				.tint(.black)
		}
}

struct CuddleTabItem: View {
		let activeImage: String
		let inactiveImage: String
		let label: String
		let isActive: Bool

		var body: some View {

				VStack {
						if isActive {
								Image(activeImage)

								Text(label)
										.cuddleFont(size: 10, weight: .medium)

						} else {
								Image(inactiveImage)
								Text(label)
										.cuddleFont(size: 10, weight: .regular)
										.foregroundStyle(.greyABAD)
						}

				}
		}
}

#Preview {
		DashboardView()
}
