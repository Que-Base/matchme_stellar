//
//  chatView.swift
//  matchme.mobile_swift
//
//  Created by Gideon Adewuyi on 30/08/2024.
//
//  ISS-010: Replaces Text("Chat View") placeholder with a structured stub —
//  conversation list with rows, empty state, and navigation to detail screen.
//

import SwiftUI
import SwiftfulRouting

struct ChatView: View {

    @Environment(\.router) var router
    @Environment(AuthViewModel.self) private var authViewModel

    @State private var viewModel = ChatViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // MARK: Header
                HStack {
                    Text("Chats")
                        .cuddleFont(size: 28, weight: .bold)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)

                // MARK: Content
                if viewModel.isLoadingConversations {
                    Spacer()
                    CuddleLoadingView()
                    Spacer()

                } else if viewModel.conversations.isEmpty {
                    Spacer()
                    ChatsEmptyStateView()
                    Spacer()

                } else {
                    // ISS-010c — conversation list
                    List {
                        ForEach(viewModel.conversations) { conversation in
                            NavigationLink {
                                ConversationDetailView(
                                    conversation: conversation,
                                    currentUserID: authViewModel.currentUser?.id ?? ""
                                )
                            } label: {
                                ConversationRowView(conversation: conversation)
                            }
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .task {
                await viewModel.fetchConversations(
                    currentUserID: authViewModel.currentUser?.id ?? ""
                )
            }
        }
    }
}

// MARK: - Empty state

private struct ChatsEmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "bubble.left.and.bubble.right")
                .resizable()
                .scaledToFit()
                .frame(width: 64)
                .foregroundStyle(.gradientDark.opacity(0.4))

            Text("No conversations yet")
                .cuddleFont(size: 22, weight: .bold)

            Text("Match with someone on Explore\nto start chatting.")
                .cuddleFont(size: 15, weight: .regular)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
    }
}

#Preview {
    ChatView()
}
