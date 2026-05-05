//
//  settingsView.swift
//  cuddleme.mobile_swift
//
//  Created by Gideon Adewuyi on 31/08/2024.
//

import SwiftUI
import SwiftfulRouting

struct SettingsView: View {
		let router: AnyRouter
		var body: some View {
				NavigationStack {
						Section {
							Divider()
								NavigationLink(
										destination: {},
										label: {
												HStack {
														Text("Connect social media account")
																.cuddleFont(size: 16)
																.foregroundStyle(.black)
														Spacer()
														Image("arrow_down_icon")
																.rotationEffect(.degrees(-90))
												}
										}
								)
							Divider()
						}
				}.padding(.horizontal, 24)
		}
}

#Preview {
		RouterView { router in
				SettingsView(router: router)
		}
}
