//
//  profileViewModel.swift
//  cuddleme.mobile_swift
//
//  Created by Gideon Adewuyi on 07/09/2024.
//

import SwiftUI

@Observable class ProfileViewModel {
    var firstName: String
    var lastName: String
    var bio: String
    var occupation: String
    var intersets: [String]
    var age: Int
    var isPremiumUser: Bool
    var profileSetupComplition: Double
    var images: [String]
    var profileImage: String

    init(
        firstName: String,
        lastName: String,
        occupation: String,
        intersets: [String],
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
        self.intersets = intersets
        self.age = age
        self.isPremiumUser = premiumAccount
        self.profileSetupComplition = profileSetupComplition
        self.bio = bio
        self.images = images
        self.profileImage = profileImage
    }

}

extension ProfileViewModel {
    static func jostevModel(
        firstName: String? = nil,
        lastName: String? = nil,
        occupation: String? = nil,
        intersets: [String]? = nil,
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
            intersets: intersets ?? ["Hiking"],
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
            intersets: [""],
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
