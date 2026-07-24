//
//  ConversationRowView.swift
//  matchme.mobile_swift
//
//  Created by Gideon Adewuyi on 24/07/2026.
//
//  ISS-010c: Stub — single row in the conversation list.
//

import SwiftUI

struct ConversationRowView: View {

    let conversation: Conversation

    var body: some View {
        HStack(spacing: 14) {

            // Avatar
            AsyncImage(url: URL(string: conversation.matchedUserPhotoURL ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    Circle()
                        .fill(LinearGradient(
                            colors: [.gradientDark.opacity(0.4), .gradientLight.opacity(0.4)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ))
                        .overlay(Image(systemName: "person.fill")
                            .foregroundStyle(.white.opacity(0.7)))
                }
            }
            .frame(width: 54, height: 54)
            .clipShape(Circle())

            // Name + last message
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(conversation.matchedUserName)
                        .cuddleFont(size: 16, weight: .bold)
                        .foregroundStyle(.primary)
                    Spacer()
                    Text(conversation.lastMessageDate, style: .relative)
                        .cuddleFont(size: 12, weight: .regular)
                        .foregroundStyle(.secondary)
                }
                Text(conversation.lastMessage)
                    .cuddleFont(size: 14, weight: .regular)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            // Unread badge
            if conversation.unreadCount > 0 {
                Text("\(conversation.unreadCount)")
                    .cuddleFont(size: 12, weight: .bold)
                    .foregroundStyle(.white)
                    .padding(6)
                    .background(appLinearGradient)
                    .clipShape(Circle())
            }
        }
        .padding(.vertical, 6)
    }
}
