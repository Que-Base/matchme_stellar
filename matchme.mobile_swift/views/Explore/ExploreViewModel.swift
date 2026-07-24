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
}

@Observable
final class ExploreViewModel {

    // MARK: - State

    /// Profiles queued up for swiping. Top of the stack is last in the array.
    var profiles: [ExploreProfile] = []
    var isLoading: Bool = false
    var errorMessage: String?

    // MARK: - Firestore

    private let db = Firestore.firestore()

    // MARK: - Fetch

    /// ISS-008a — Stub. Fetches candidate profiles from Firestore.
    /// TODO: exclude current user, already-liked UIDs, already-passed UIDs.
    func fetchProfiles(currentUserID: String) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let snapshot = try await db
                .collection("users")
                .limit(to: 20)
                .getDocuments()

            profiles = snapshot.documents.compactMap { doc -> ExploreProfile? in
                let data = doc.data()
                guard doc.documentID != currentUserID else { return nil }
                return ExploreProfile(
                    id: doc.documentID,
                    fullname: data["fullname"] as? String ?? "Unknown",
                    age: data["age"] as? Int,
                    occupation: data["occupation"] as? String,
                    interests: data["interests"] as? [String] ?? [],
                    photoURL: (data["photoURLs"] as? [String])?.first
                )
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Actions

    /// ISS-008g — Stub. Persists a like to Firestore and removes the card.
    /// TODO: write to `likes/{currentUID}/liked/{targetUID}`, then call checkForMatch().
    func like(profile: ExploreProfile, currentUserID: String) {
        removeTopCard()
        // TODO: persist like, check for mutual match (ISS-008h)
    }

    /// ISS-008g — Stub. Persists a pass to Firestore and removes the card.
    /// TODO: write to `passes/{currentUID}/passed/{targetUID}`.
    func pass(profile: ExploreProfile, currentUserID: String) {
        removeTopCard()
        // TODO: persist pass
    }

    /// ISS-008e — Stub. Super like — same as like but flagged.
    /// TODO: deduct 20 MATCH tokens (ISS-026f), write superLike flag.
    func superLike(profile: ExploreProfile, currentUserID: String) {
        removeTopCard()
        // TODO: persist super like, deduct MATCH tokens
    }

    // MARK: - Helpers

    private func removeTopCard() {
        guard !profiles.isEmpty else { return }
        profiles.removeLast()
    }
}
