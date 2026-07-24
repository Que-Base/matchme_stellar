//
//  ConversationDetailView.swift
//  matchme.mobile_swift
//
//  Created by Gideon Adewuyi on 24/07/2026.
//
//  ISS-010d: Stub — individual chat screen with message bubbles and send bar.
//  TODO: wire real-time listener (ISS-010e), read receipts (ISS-010g).
//

import SwiftUI

struct ConversationDetailView: View {

    let conversation: Conversation
    let currentUserID: String

    @State private var viewModel = ChatViewModel()

    var body: some View {
        VStack(spacing: 0) {

            // MARK: Messages list
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        if viewModel.isLoadingMessages {
                            ProgressView().padding()
                        } else if viewModel.messages.isEmpty {
                            Text("No messages yet. Say hello! 👋")
                                .cuddleFont(size: 14, weight: .regular)
                                .foregroundStyle(.secondary)
                                .padding(.top, 40)
                        } else {
                            ForEach(viewModel.messages) { message in
                                MessageBubble(
                                    message: message,
                                    isFromCurrentUser: message.senderID == currentUserID
                                )
                                .id(message.id)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .onChange(of: viewModel.messages.count) {
                    if let last = viewModel.messages.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }

            Divider()

            // MARK: Input bar
            HStack(spacing: 12) {
                TextField("Message...", text: $viewModel.draftText, axis: .vertical)
                    .cuddleFont(size: 15, weight: .regular)
                    .lineLimit(1...4)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                Button {
                    viewModel.sendMessage(
                        conversationID: conversation.id,
                        senderID: currentUserID
                    )
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .resizable()
                        .frame(width: 36, height: 36)
                        .foregroundStyle(appLinearGradient)
                }
                .disabled(viewModel.draftText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .navigationTitle(conversation.matchedUserName)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchMessages(conversationID: conversation.id)
        }
    }
}

// MARK: - Message bubble

private struct MessageBubble: View {

    let message: Message
    let isFromCurrentUser: Bool

    var body: some View {
        HStack {
            if isFromCurrentUser { Spacer(minLength: 60) }
            Text(message.text)
                .cuddleFont(size: 15, weight: .regular)
                .foregroundStyle(isFromCurrentUser ? .white : .primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    isFromCurrentUser
                        ? AnyShapeStyle(appLinearGradient)
                        : AnyShapeStyle(Color(.systemGray5))
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 18)
                )
            if !isFromCurrentUser { Spacer(minLength: 60) }
        }
    }
}
