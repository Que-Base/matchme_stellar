//
//  ExploreViewModel.swift
//  matchme.mobile_swift
//
//  Created by Gideon Adewuyi on 24/07/2026.
//
//  ISS-008: Stub — fetch, like, and pass logic to be implemented.
//

import SwiftUI
import FirebaseFirestore

/// Represents a minimal profile shown on an explore card.
/// Expand alongside `User` model when ISS-012 adds bio/age/interests/photoURLs.
struct ExploreProfile: Identifiable {
    let id: String
    let fullname: String
    let age: Int?
    let occupation: String?
    let interests: [String]
    /// First remote photo URL. Falls back to nil (card shows placeholder).
    let photoURL: String?
    /// Stellar public key of the target user (used for reward payouts).
    let stellarPublicKey: String?
}

@Observable
final class ExploreViewModel {

    // MARK: - State

    /// Profiles queued up for swiping. Top of the stack is last in the array.
    var profiles: [ExploreProfile] = []
    var isLoading: Bool = false
    var errorMessage: String?

    // MARK: - Pagination & Exclusion State (ISS-052)

    private var lastDocument: DocumentSnapshot?
    private var isFetchingMore: Bool = false
    private var hasMoreProfiles: Bool = true
    private var excludedUIDs: Set<String> = []

    // MARK: - Firestore

    private let db = Firestore.firestore()

    // MARK: - Fetch

    /// ISS-052a/b — Candidate profile fetch excluding current user, already-liked UIDs, and already-passed UIDs.
    func fetchProfiles(currentUserID: String, isInitialLoad: Bool = true) async {
        guard !currentUserID.isEmpty else { return }

        if isInitialLoad {
            isLoading = true
            lastDocument = nil
            hasMoreProfiles = true
            excludedUIDs = [currentUserID]
        } else {
            guard !isFetchingMore && hasMoreProfiles else { return }
            isFetchingMore = true
        }

        defer {
            isLoading = false
            isFetchingMore = false
        }

        do {
            // ISS-052a: Fetch liked and passed UIDs on initial load
            if isInitialLoad {
                let likedSnapshot = try? await db
                    .collection("likes")
                    .document(currentUserID)
                    .collection("liked")
                    .getDocuments()

                let passedSnapshot = try? await db
                    .collection("passes")
                    .document(currentUserID)
                    .collection("passed")
                    .getDocuments()

                if let likedDocs = likedSnapshot?.documents {
                    excludedUIDs.formUnion(likedDocs.map { $0.documentID })
                }
                if let passedDocs = passedSnapshot?.documents {
                    excludedUIDs.formUnion(passedDocs.map { $0.documentID })
                }
            }

            var query: Query = db
                .collection("users")
                .limit(to: 20)

            if let lastDoc = lastDocument {
                query = query.start(afterDocument: lastDoc)
            }

            let snapshot = try await query.getDocuments()

            if snapshot.documents.isEmpty {
                hasMoreProfiles = false
                if isInitialLoad {
                    profiles = []
                }
                return
            }

            lastDocument = snapshot.documents.last

            let newProfiles = snapshot.documents.compactMap { doc -> ExploreProfile? in
                let docID = doc.documentID
                guard !excludedUIDs.contains(docID) else { return nil }

                let data = doc.data()
                return ExploreProfile(
                    id: docID,
                    fullname: data["fullname"] as? String ?? "Unknown",
                    age: data["age"] as? Int,
                    occupation: data["occupation"] as? String,
                    interests: data["interests"] as? [String] ?? [],
                    photoURL: (data["photoURLs"] as? [String])?.first,
                    stellarPublicKey: data["stellarPublicKey"] as? String
                )
            }

            if isInitialLoad {
                profiles = newProfiles
            } else {
                // Prepend new profiles to bottom of stack (since top of stack is last element)
                profiles.insert(contentsOf: newProfiles, at: 0)
            }
        } catch {
            errorMessage = error.localizedDescription
            print("ExploreViewModel: fetchProfiles error: \(error.localizedDescription)")
        }
    }

    // MARK: - Actions

    /// ISS-051a/d — Persists a like to Firestore, triggers reward, checks for mutual match, and removes top card.
    func like(profile: ExploreProfile, currentUserID: String, userPublicKey: String? = nil) {
        removeTopCard(currentUserID: currentUserID)
        guard !currentUserID.isEmpty else { return }

        Task {
            let targetID = profile.id

            // Write to likes/{currentUID}/liked/{targetID}
            try? await db
                .collection("likes")
                .document(currentUserID)
                .collection("liked")
                .document(targetID)
                .setData([
                    "timestamp": FieldValue.serverTimestamp(),
                    "isSuperLike": false
                ])

            // Write to likes/{targetID}/likedBy/{currentUID}
            try? await db
                .collection("likes")
                .document(targetID)
                .collection("likedBy")
                .document(currentUserID)
                .setData([
                    "timestamp": FieldValue.serverTimestamp(),
                    "isSuperLike": false
                ])

            // ISS-051d: Trigger received-like reward for target user if key is present
            if let targetPublicKey = profile.stellarPublicKey {
                await RewardService.shared.onReceivedLike(
                    likedUserID: targetID,
                    fromUserID: currentUserID,
                    likedUserPublicKey: targetPublicKey
                )
            }

            // ISS-051c: Check for mutual match
            await checkForMatch(
                currentUserID: currentUserID,
                targetProfile: profile,
                userPublicKey: userPublicKey
            )
        }
    }

    /// ISS-051b — Persists a pass to Firestore (`passes/{currentUID}/passed/{targetUID}`) and removes top card.
    func pass(profile: ExploreProfile, currentUserID: String) {
        removeTopCard(currentUserID: currentUserID)
        guard !currentUserID.isEmpty else { return }

        Task {
            let targetID = profile.id
            try? await db
                .collection("passes")
                .document(currentUserID)
                .collection("passed")
                .document(targetID)
                .setData([
                    "timestamp": FieldValue.serverTimestamp()
                ])
        }
    }

    /// Super like — charges 20 MATCH, persists flagged like to Firestore, checks for mutual match, and removes top card.
    func superLike(profile: ExploreProfile, currentUserID: String, userPublicKey: String? = nil) {
        removeTopCard(currentUserID: currentUserID)
        guard !currentUserID.isEmpty else { return }

        Task {
            let targetID = profile.id

            // Deduct 20 MATCH tokens
            if let publicKey = userPublicKey {
                await RewardService.shared.onSuperLikeSent(
                    userID: currentUserID,
                    toUserID: targetID,
                    publicKey: publicKey
                )
            }

            // Write flagged like to likes/{currentUID}/liked/{targetID}
            try? await db
                .collection("likes")
                .document(currentUserID)
                .collection("liked")
                .document(targetID)
                .setData([
                    "timestamp": FieldValue.serverTimestamp(),
                    "isSuperLike": true
                ])

            // Write to likes/{targetID}/likedBy/{currentUID}
            try? await db
                .collection("likes")
                .document(targetID)
                .collection("likedBy")
                .document(currentUserID)
                .setData([
                    "timestamp": FieldValue.serverTimestamp(),
                    "isSuperLike": true
                ])

            // Trigger received-like reward for target user
            if let targetPublicKey = profile.stellarPublicKey {
                await RewardService.shared.onReceivedLike(
                    likedUserID: targetID,
                    fromUserID: currentUserID,
                    likedUserPublicKey: targetPublicKey
                )
            }

            // Check for mutual match
            await checkForMatch(
                currentUserID: currentUserID,
                targetProfile: profile,
                userPublicKey: userPublicKey
            )
        }
    }

    // MARK: - Helpers

    /// ISS-051c — Checks if target user has already liked current user. If so, creates conversation and triggers match reward.
    private func checkForMatch(currentUserID: String, targetProfile: ExploreProfile, userPublicKey: String? = nil) async {
        let targetID = targetProfile.id

        do {
            let likedByDoc = try await db
                .collection("likes")
                .document(currentUserID)
                .collection("likedBy")
                .document(targetID)
                .getDocument()

            if likedByDoc.exists {
                // Mutual match! Create conversation
                let conversationID = [currentUserID, targetID].sorted().joined(separator: "_")
                let conversationRef = db.collection("conversations").document(conversationID)

                let conversationData: [String: Any] = [
                    "participants": [currentUserID, targetID],
                    "lastMessage": "You matched! Say hi 👋",
                    "lastMessageTimestamp": FieldValue.serverTimestamp(),
                    "createdAt": FieldValue.serverTimestamp()
                ]

                try await conversationRef.setData(conversationData, merge: true)

                // ISS-051d: Trigger +100 MATCH reward for mutual match
                if let publicKey = userPublicKey {
                    await RewardService.shared.onMutualMatch(
                        userID: currentUserID,
                        matchedUserID: targetID,
                        publicKey: publicKey
                    )
                }

                print("ExploreViewModel: Mutual match created with \(targetProfile.fullname) [conversation: \(conversationID)]")
            }
        } catch {
            print("ExploreViewModel: checkForMatch error: \(error.localizedDescription)")
        }
    }

    private func removeTopCard(currentUserID: String = "") {
        guard !profiles.isEmpty else { return }
        profiles.removeLast()

        // ISS-052c: Auto-prefetch next page of candidate profiles when stack runs low (<= 3 cards remaining)
        if profiles.count <= 3 && !currentUserID.isEmpty {
            Task {
                await fetchProfiles(currentUserID: currentUserID, isInitialLoad: false)
            }
        }
    }
}
