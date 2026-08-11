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

    /// ISS-009d — Stub. Like back — triggers a match if mutual.
    /// TODO: write to Firestore likes collection, then call match detection (ISS-054).
    func likeBack(profile: LikedByProfile, currentUserID: String) {
        profiles.removeAll { $0.id == profile.id }
        // TODO: persist like, trigger match event (ISS-054)
    }

    /// ISS-009d — Stub. Pass on a profile that liked you.
    /// TODO: write to Firestore passes collection (ISS-054).
    func pass(profile: LikedByProfile, currentUserID: String) {
        profiles.removeAll { $0.id == profile.id }
        // TODO: persist pass (ISS-054)
    }
}
