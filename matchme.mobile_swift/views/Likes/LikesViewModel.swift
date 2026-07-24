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
}

@Observable
final class LikesViewModel {

    // MARK: - State

    var profiles: [LikedByProfile] = []
    var isLoading: Bool = false
    var errorMessage: String?

    private let db = Firestore.firestore()

    // MARK: - Fetch

    /// ISS-009a — Stub. Queries `likes/{currentUID}/likedBy` subcollection,
    /// then resolves each UID into a full profile from `users/{uid}`.
    /// TODO: implement subcollection query once like persistence (ISS-008g) is done.
    func fetchLikes(currentUserID: String) async {
        isLoading = true
        defer { isLoading = false }

        // Placeholder: returns empty until ISS-008g writes the likes subcollection.
        // Replace with:
        //   db.collection("likes").document(currentUserID).collection("likedBy").getDocuments()
        profiles = []
    }

    // MARK: - Actions

    /// ISS-009d — Stub. Like back — triggers a match if mutual.
    /// TODO: write to Firestore likes collection, then call match detection.
    func likeBack(profile: LikedByProfile, currentUserID: String) {
        profiles.removeAll { $0.id == profile.id }
        // TODO: persist like, trigger match event (ISS-008h)
    }

    /// ISS-009d — Stub. Pass on a profile that liked you.
    /// TODO: write to Firestore passes collection.
    func pass(profile: LikedByProfile, currentUserID: String) {
        profiles.removeAll { $0.id == profile.id }
        // TODO: persist pass
    }
}
