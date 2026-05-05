//
//  chatView.swift
//  cuddleme.mobile_swift
//
//  Created by Gideon Adewuyi on 30/08/2024.
//
import SwiftUI
import SwiftfulRouting

struct ChatView: View {
		@Environment(\.router) var router
		var body: some View {
				VStack {
						Text("Chat View")
				}.navigationTitle(Text("Chat View"))
		}
}

#Preview {

		ChatView()

}
