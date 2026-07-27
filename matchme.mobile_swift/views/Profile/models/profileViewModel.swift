//
//  profileViewModel.swift
//  matchme.mobile_swift
//
//  Created by Gideon Adewuyi on 07/09/2024.
//

import SwiftUI

@Observable class ProfileViewModel {
    var firstName: String
    var lastName: String
    var bio: String
    var occupation: String
    var interests: [String]   // was: intersets (ISS-047 typo fixed)
    var age: Int
    var isPremiumUser: Bool
    var profileSetupComplition: Double
    var images: [String]
    var profileImage: String

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
        profileImage: String
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
    }

    // ISS-012a/b — build a ProfileViewModel from a real Firebase User.
    // Falls back to empty/placeholder values for any fields not yet set.
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
            profileImage: user.photoURLs?.first ?? ""
        )
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
