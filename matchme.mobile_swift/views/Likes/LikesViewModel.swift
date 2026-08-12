//
//  LikesViewModel.swift
//  matchme.mobile_swift
//
//  Created by Gideon Adewuyi on 24/07/2026.
//
//  ISS-009: Stub — fetch users who liked the current user.
//  TODO: persist like-back / pass decisions to Firestore.
//

import SwiftUI
import FirebaseFirestore

/// A profile that has liked the current user.
struct LikedByProfile: Identifiable {
    let id: String
    let fullname: String
    let age: Int?
    let occupation: String?
    let photoURL: String?
    let stellarPublicKey: String?
}

@Observable
final class LikesViewModel {

    // MARK: - State

    var profiles: [LikedByProfile] = []
    var isLoading: Bool = false
    var errorMessage: String?

    private let db = Firestore.firestore()

    // MARK: - Fetch

    /// ISS-053 — Queries `likes/{currentUID}/likedBy` subcollection,
    /// then resolves each UID into a full profile from `users/{uid}`.
    func fetchLikes(currentUserID: String) async {
        guard !currentUserID.isEmpty else {
            profiles = []
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let likedBySnapshot = try await db
                .collection("likes")
                .document(currentUserID)
                .collection("likedBy")
                .getDocuments()

            let uids = likedBySnapshot.documents.map { $0.documentID }

            if uids.isEmpty {
                profiles = []
                return
            }

            // Fetch user documents for each UID that liked the current user
            var fetchedProfiles: [LikedByProfile] = []
            for uid in uids {
                do {
                    let userDoc = try await db.collection("users").document(uid).getDocument()
                    if userDoc.exists, let data = userDoc.data() {
                        let profile = LikedByProfile(
                            id: uid,
                            fullname: data["fullname"] as? String ?? "Unknown",
                            age: data["age"] as? Int,
                            occupation: data["occupation"] as? String,
                            photoURL: (data["photoURLs"] as? [String])?.first,
                            stellarPublicKey: data["stellarPublicKey"] as? String
                        )
                        fetchedProfiles.append(profile)
                    }
                } catch {
                    print("LikesViewModel: Failed to fetch profile for UID \(uid): \(error.localizedDescription)")
                }
            }

            profiles = fetchedProfiles
        } catch {
            errorMessage = error.localizedDescription
            print("LikesViewModel: Error fetching likes: \(error.localizedDescription)")
        }
    }

    // MARK: - Actions

    /// ISS-054a/b — Persists a like-back to Firestore, deletes from `likedBy`, triggers rewards & mutual match creation.
    func likeBack(profile: LikedByProfile, currentUserID: String, userPublicKey: String? = nil) {
        profiles.removeAll { $0.id == profile.id }
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

            // Remove target from current user's likedBy subcollection
            try? await db
                .collection("likes")
                .document(currentUserID)
                .collection("likedBy")
                .document(targetID)
                .delete()

            // Trigger received-like reward for target user if key is present
            if let targetPublicKey = profile.stellarPublicKey {
                await RewardService.shared.onReceivedLike(
                    likedUserID: targetID,
                    fromUserID: currentUserID,
                    likedUserPublicKey: targetPublicKey
                )
            }

            // Create mutual match & conversation since target user had already liked current user
            await createMutualMatch(
                currentUserID: currentUserID,
                targetProfile: profile,
                userPublicKey: userPublicKey
            )
        }
    }

    /// ISS-054c — Persists a pass on a user who liked you to Firestore (`passes/{currentUID}/passed/{targetUID}`) and removes from `likedBy`.
    func pass(profile: LikedByProfile, currentUserID: String) {
        profiles.removeAll { $0.id == profile.id }
        guard !currentUserID.isEmpty else { return }

        Task {
            let targetID = profile.id

            // Write to passes/{currentUID}/passed/{targetID}
            try? await db
                .collection("passes")
                .document(currentUserID)
                .collection("passed")
                .document(targetID)
                .setData([
                    "timestamp": FieldValue.serverTimestamp()
                ])

            // Remove target from current user's likedBy subcollection
            try? await db
                .collection("likes")
                .document(currentUserID)
                .collection("likedBy")
                .document(targetID)
                .delete()
        }
    }

    // MARK: - Helpers

    /// ISS-054b — Creates a conversation for a mutual match and triggers the match reward (+100 MATCH).
    private func createMutualMatch(currentUserID: String, targetProfile: LikedByProfile, userPublicKey: String? = nil) async {
        let targetID = targetProfile.id
        let conversationID = [currentUserID, targetID].sorted().joined(separator: "_")
        let conversationRef = db.collection("conversations").document(conversationID)

        do {
            let conversationData: [String: Any] = [
                "participants": [currentUserID, targetID],
                "lastMessage": "You matched! Say hi 👋",
                "lastMessageTimestamp": FieldValue.serverTimestamp(),
                "createdAt": FieldValue.serverTimestamp()
            ]

            try await conversationRef.setData(conversationData, merge: true)

            // Trigger +100 MATCH reward for mutual match
            if let publicKey = userPublicKey {
                await RewardService.shared.onMutualMatch(
                    userID: currentUserID,
                    matchedUserID: targetID,
                    publicKey: publicKey
                )
            }

            print("LikesViewModel: Mutual match created with \(targetProfile.fullname) [conversation: \(conversationID)]")
        } catch {
            print("LikesViewModel: createMutualMatch error: \(error.localizedDescription)")
        }
    }
}
