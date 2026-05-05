//
//  cuddleProfileImage.swift
//  cuddleme.mobile_swift
//
//  Created by Gideon Adewuyi on 06/09/2024.
//

import SwiftUI

struct CuddleProfileInfoView: View {
    var profile: ProfileViewModel
    var body: some View {
        HStack {
          CircularProfilePictureView(profileModel: profile)
            .padding(.trailing, 20.0)
            VStack(alignment: .leading) {
                HStack {
                    Text(profile.firstName)
                        .cuddleFont(.Athletics, size: 30, weight: .bold)
                    Text(profile.age.formatted())
                        .cuddleFont(size: 17, weight: .medium)
                    if profile.isPremiumUser {
                        Image("crown_icon")
                    }

                }

                Text(profile.occupation)
                    .cuddleFont(size: 10, weight: .medium)
                    .padding(.bottom, 12)

              if profile.profileSetupComplition < 1.0 {
                    Button(action: {

                    }) {
                        Text("Complete my profile")
                            .cuddleFont(size: 10, weight: .medium)
                            .foregroundStyle(.black)
                            .padding(.horizontal, 11).padding(.vertical, 7)
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
