//
//  profileToolBar.swift
//  cuddleme.mobile_swift
//
//  Created by Gideon Adewuyi on 30/08/2024.
//

import SwiftUI

struct ProfileToolBar: ToolbarContent {
    let setting: () -> Void
    let notification: () -> Void
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Text("Profile")
                .cuddleFont(.Athletics, size: 24, weight: .bold)
        }

        ToolbarItemGroup(placement: .topBarTrailing) {
            Button(action: notification) {
                Label(
                    title: { Text("Notification") },
                    icon: { Image("notification_icon") }
                )

            }
            Button(action: setting) {
                Label(
                    title: { Text("Settings") },
                    icon: { Image("setting_icon") }
                )
            }
        }
    }
}
