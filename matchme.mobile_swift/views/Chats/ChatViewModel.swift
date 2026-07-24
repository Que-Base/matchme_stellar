//
//  ChatViewModel.swift
//  matchme.mobile_swift
//
//  Created by Gideon Adewuyi on 24/07/2026.
//
//  ISS-010a/b: Stub — Conversation + Message models, fetch and send stubs.
//  TODO: wire real-time Firestore listeners (ISS-010e).
//

import SwiftUI
import FirebaseFirestore

// MARK: - Models

/// ISS-010a — top-level conversation between two matched users.
struct Conversation: Identifiable {
    let id: String
    let matchedUserID: String
    let matchedUserName: String
    let matchedUserPhotoURL: String?
    var lastMessage: String
    var lastMessageDate: Date
    var unreadCount: Int
}

/// ISS-010b — a single message inside a conversation.
struct Message: Identifiable {
    let id: String
    let senderID: String
    let text: String
    let date: Date
}

// MARK: - ViewModel

@Observable
final class ChatViewModel {

    // MARK: Conversation list state
    var conversations: [Conversation] = []
    var isLoadingConversations: Bool = false

    // MARK: Active conversation state
    var messages: [Message] = []
    var isLoadingMessages: Bool = false
    var draftText: String = ""

    var errorMessage: String?

    private let db = Firestore.firestore()

    // MARK: - ISS-010c: Fetch conversation list

    /// Stub. Queries `conversations` collection filtered by current user.
    /// TODO: replace with real-time addSnapshotListener (ISS-010e).
    func fetchConversations(currentUserID: String) async {
        isLoadingConversations = true
        defer { isLoadingConversations = false }

        // Placeholder until match + conversation creation (ISS-008h) is implemented.
        // Replace with:
        //   db.collection("conversations")
        //     .whereField("participants", arrayContains: currentUserID)
        //     .order(by: "lastMessageDate", descending: true)
        //     .getDocuments()
        conversations = []
    }

    // MARK: - ISS-010d: Fetch messages for a conversation

    /// Stub. Queries `conversations/{id}/messages` subcollection.
    /// TODO: replace with real-time listener (ISS-010e).
    func fetchMessages(conversationID: String) async {
        isLoadingMessages = true
        defer { isLoadingMessages = false }

        // Replace with:
        //   db.collection("conversations").document(conversationID)
        //     .collection("messages").order(by: "date").getDocuments()
        messages = []
    }

    // MARK: - ISS-010f: Send a message

    /// Stub. Writes a new message to the messages subcollection and updates
    /// the conversation's lastMessage field.
    func sendMessage(conversationID: String, senderID: String) {
        guard !draftText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let text = draftText
        draftText = ""

        // TODO: write to Firestore:
        //   db.collection("conversations").document(conversationID)
        //     .collection("messages").addDocument(data: [...])
        //   db.collection("conversations").document(conversationID)
        //     .updateData(["lastMessage": text, "lastMessageDate": Date()])
        _ = text
    }
}
