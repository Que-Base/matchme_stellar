//
//  cuddleProfileImage.swift
//  matchme.mobile_swift
//
//  Created by Gideon Adewuyi on 06/09/2024.
//

import SwiftUI

struct CuddleProfileInfoView: View {
    var profile: ProfileViewModel
    var onEditProfile: (() -> Void)? = nil

    var body: some View {
        HStack {
            CircularProfilePictureView(profileModel: profile)
                .padding(.trailing, 20.0)
            VStack(alignment: .leading) {
                HStack {
                    Text(profile.firstName)
                        .cuddleFont(.Athletics, size: 30, weight: .bold)
                    Text(profile.age > 0 ? profile.age.formatted() : "")
                        .cuddleFont(size: 17, weight: .medium)
                    if profile.isPremiumUser {
                        Image("crown_icon")
                    }
                }

                Text(profile.occupation)
                    .cuddleFont(size: 10, weight: .medium)
                    .padding(.bottom, 12)

                // ISS-015 / ISS-072: Wired to edit/complete profile flow
                if let onEditProfile {
                    Button(action: onEditProfile) {
                        HStack(spacing: 4) {
                            Image(systemName: "pencil")
                                .font(.system(size: 10, weight: .medium))
                            Text(profile.profileSetupComplition < 1.0 ? "Complete my profile" : "Edit profile")
                                .cuddleFont(size: 10, weight: .medium)
                        }
                        .foregroundStyle(.black)
                        .padding(.horizontal, 11)
                        .padding(.vertical, 7)
                    }
                    .background(.whiteF6, in: Capsule())
                } else {
                    NavigationLink {
                        ProfileSetupView()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "pencil")
                                .font(.system(size: 10, weight: .medium))
                            Text(profile.profileSetupComplition < 1.0 ? "Complete my profile" : "Edit profile")
                                .cuddleFont(size: 10, weight: .medium)
                        }
                        .foregroundStyle(.black)
                        .padding(.horizontal, 11)
                        .padding(.vertical, 7)
                    }
                    .background(.whiteF6, in: Capsule())
                }
            }
        }
    }
}

#Preview {
    CuddleProfileInfoView(
        profile: ProfileViewModel.jostevModel(
            premiumAccount: true,
            profileSetupComplition: 0.4
        )
    )
}
