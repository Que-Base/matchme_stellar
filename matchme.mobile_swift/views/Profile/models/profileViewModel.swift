//
//  profileViewModel.swift
//  matchme.mobile_swift
//
//  Created by Gideon Adewuyi on 07/09/2024.
//
//  ISS-038: Added Firestore write-back so profile edits persist across
//  sessions. updateProfile() writes all fields; updateField() writes
//  a single key for lightweight partial updates.
//

import SwiftUI
import FirebaseFirestore

@Observable class ProfileViewModel {
    var firstName: String
    var lastName: String
    var bio: String
    var occupation: String
    var interests: [String]
    var age: Int
    var isPremiumUser: Bool
    var profileSetupComplition: Double
    var images: [String]
    var profileImage: String

    /// Set when this VM is backed by a real Firestore document.
    private var userID: String?

    private let db = Firestore.firestore()

    // MARK: - Inits

    init(
        firstName: String,
        lastName: String,
        occupation: String,
        interests: [String],
        age: Int,
        premiumAccount: Bool,
        profileSetupComplition: Double,
        bio: String,
        images: [String],
        profileImage: String,
        userID: String? = nil
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.occupation = occupation
        self.interests = interests
        self.age = age
        self.isPremiumUser = premiumAccount
        self.profileSetupComplition = profileSetupComplition
        self.bio = bio
        self.images = images
        self.profileImage = profileImage
        self.userID = userID
    }

    /// ISS-012a/b — build from a real Firebase User, storing the UID for write-back.
    convenience init(from user: User) {
        let parts = user.fullname.split(separator: " ", maxSplits: 1)
        self.init(
            firstName: parts.first.map(String.init) ?? user.fullname,
            lastName: parts.dropFirst().first.map(String.init) ?? "",
            occupation: user.occupation ?? "",
            interests: user.interests ?? [],
            age: user.age ?? 0,
            premiumAccount: user.isPremiumUser ?? false,
            profileSetupComplition: user.profileSetupCompletion ?? 0.1,
            bio: user.bio ?? "",
            images: user.photoURLs ?? [],
            profileImage: user.photoURLs?.first ?? "",
            userID: user.id
        )
    }

    // MARK: - ISS-038: Firestore write-back

    /// Writes all editable profile fields to Firestore.
    /// Call after a batch edit (e.g. save button in ProfileSetupView).
    func updateProfile() async throws {
        guard let uid = userID else { return }
        let fullname = [firstName, lastName]
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        try await db.collection("users").document(uid).updateData([
            "fullname": fullname,
            "bio": bio,
            "occupation": occupation,
            "age": age,
            "interests": interests,
            "profileSetupCompletion": profileSetupComplition
        ])
    }

    /// Writes a single field to Firestore — use for lightweight toggles
    /// or inline edits that don't require a full save action.
    /// Example: `try await vm.updateField("bio", value: newBio)`
    func updateField(_ key: String, value: Any) async throws {
        guard let uid = userID else { return }
        try await db.collection("users").document(uid).updateData([key: value])
    }

}


extension ProfileViewModel {
    static func jostevModel(
        firstName: String? = nil,
        lastName: String? = nil,
        occupation: String? = nil,
        interests: [String]? = nil,
        age: Int? = nil,
        premiumAccount: Bool,
        profileSetupComplition: Double,
        bio: String? = nil,
        images: [String]? = nil,
        profileImages: String? = nil
    ) -> ProfileViewModel {
        return ProfileViewModel(
            firstName: firstName ?? "Josteve",
            lastName: lastName ?? "Amshatir",
            occupation: occupation ?? "Product Designer",
            interests: interests ?? ["Hiking"],
            age: age ?? 28,
            premiumAccount: premiumAccount,
            profileSetupComplition: profileSetupComplition,
            bio: bio ?? profileBio,
            images: images ?? ["mock_cat", "mock_cat"],
            profileImage: "mock_cat"
        )
    }

    static func setupInit() -> ProfileViewModel {
        return ProfileViewModel(
            firstName: "",
            lastName: "",
            occupation: "",
            interests: [""],
            age: 0,
            premiumAccount: false,
            profileSetupComplition: 0.1,
            bio: "",
            images: [""],
            profileImage: ""
        )
    }
}

private let profileBio =
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."
