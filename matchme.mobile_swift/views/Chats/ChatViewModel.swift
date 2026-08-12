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
    private var conversationsListener: ListenerRegistration?
    private var messagesListener: ListenerRegistration?

    deinit {
        conversationsListener?.remove()
        messagesListener?.remove()
    }

    // MARK: - ISS-055a/d: Fetch and listen to conversation list

    /// Subscribes to real-time updates for `conversations` where `participants` array contains `currentUserID`.
    func fetchConversations(currentUserID: String) async {
        guard !currentUserID.isEmpty else {
            conversations = []
            return
        }

        isLoadingConversations = true
        errorMessage = nil

        conversationsListener?.remove()
        conversationsListener = db
            .collection("conversations")
            .whereField("participants", arrayContains: currentUserID)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                self.isLoadingConversations = false

                if let error = error {
                    self.errorMessage = error.localizedDescription
                    print("ChatViewModel: fetchConversations error: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else {
                    self.conversations = []
                    return
                }

                Task {
                    var fetchedConversations: [Conversation] = []

                    for doc in documents {
                        let data = doc.data()
                        let participants = data["participants"] as? [String] ?? []
                        guard let matchedID = participants.first(where: { $0 != currentUserID }) else {
                            continue
                        }

                        let lastMsg = data["lastMessage"] as? String ?? ""
                        let lastMsgTimestamp = (data["lastMessageTimestamp"] as? Timestamp)?.dateValue()
                            ?? (data["createdAt"] as? Timestamp)?.dateValue()
                            ?? Date()

                        // Fetch matched user details from `users/{matchedID}`
                        var matchedName = "Matched User"
                        var matchedPhotoURL: String? = nil

                        do {
                            let userDoc = try await self.db.collection("users").document(matchedID).getDocument()
                            if userDoc.exists, let userData = userDoc.data() {
                                matchedName = userData["fullname"] as? String ?? "Matched User"
                                matchedPhotoURL = (userData["photoURLs"] as? [String])?.first
                            }
                        } catch {
                            print("ChatViewModel: Failed to fetch matched user \(matchedID): \(error.localizedDescription)")
                        }

                        let conv = Conversation(
                            id: doc.documentID,
                            matchedUserID: matchedID,
                            matchedUserName: matchedName,
                            matchedUserPhotoURL: matchedPhotoURL,
                            lastMessage: lastMsg,
                            lastMessageDate: lastMsgTimestamp,
                            unreadCount: 0
                        )
                        fetchedConversations.append(conv)
                    }

                    // Sort by most recent message date
                    self.conversations = fetchedConversations.sorted(by: { $0.lastMessageDate > $1.lastMessageDate })
                }
            }
    }

    // MARK: - ISS-055b/d: Fetch and listen to messages for a conversation

    /// Subscribes to real-time updates for `conversations/{id}/messages` subcollection ordered by date ascending.
    func fetchMessages(conversationID: String) async {
        guard !conversationID.isEmpty else {
            messages = []
            return
        }

        isLoadingMessages = true
        errorMessage = nil

        messagesListener?.remove()
        messagesListener = db
            .collection("conversations")
            .document(conversationID)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                self.isLoadingMessages = false

                if let error = error {
                    self.errorMessage = error.localizedDescription
                    print("ChatViewModel: fetchMessages error: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else {
                    self.messages = []
                    return
                }

                self.messages = documents.compactMap { doc -> Message? in
                    let data = doc.data()
                    guard let senderID = data["senderID"] as? String,
                          let text = data["text"] as? String else { return nil }

                    let date = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()

                    return Message(
                        id: doc.documentID,
                        senderID: senderID,
                        text: text,
                        date: date
                    )
                }
            }
    }

    // MARK: - ISS-055c: Send a message

    /// Writes a new message to `conversations/{id}/messages` subcollection and updates the top-level conversation's `lastMessage` and `lastMessageTimestamp`.
    func sendMessage(conversationID: String, senderID: String) {
        guard !conversationID.isEmpty, !senderID.isEmpty else { return }
        let text = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        draftText = ""

        let messageData: [String: Any] = [
            "senderID": senderID,
            "text": text,
            "timestamp": FieldValue.serverTimestamp()
        ]

        let conversationRef = db.collection("conversations").document(conversationID)

        // Write message document
        conversationRef.collection("messages").addDocument(data: messageData) { [weak self] error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                print("ChatViewModel: sendMessage error: \(error.localizedDescription)")
                return
            }

            // Update conversation header fields
            conversationRef.updateData([
                "lastMessage": text,
                "lastMessageTimestamp": FieldValue.serverTimestamp()
            ])
        }
    }

    /// Stops listening to active message stream (e.g. on view disapear).
    func stopMessagesListener() {
        messagesListener?.remove()
        messagesListener = nil
    }

    /// Stops listening to active conversation list stream.
    func stopConversationsListener() {
        conversationsListener?.remove()
        conversationsListener = nil
    }
}
