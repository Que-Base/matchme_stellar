//
//  LikeCardView.swift
//  matchme.mobile_swift
//
//  Created by Gideon Adewuyi on 24/07/2026.
//
//  ISS-009b: Stub — grid card showing a profile that liked you.
//  TODO: add blur paywall for non-premium users (ISS-009f).
//

import SwiftUI

struct LikeCardView: View {

    let profile: LikedByProfile
    let onLikeBack: () -> Void
    let onPass: () -> Void

    var body: some View {
        VStack(spacing: 0) {

            // MARK: Photo
            // TODO: load from profile.photoURL (ISS-013)
            AsyncImage(url: URL(string: profile.photoURL ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                default:
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.gradientDark.opacity(0.35), .gradientLight.opacity(0.35)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            Image(systemName: "person.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 44)
                                .foregroundStyle(.white.opacity(0.5))
                        )
                }
            }
            .frame(height: 180)
            .clipped()

            // MARK: Info
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(profile.fullname)
                        .cuddleFont(size: 15, weight: .bold)
                        .lineLimit(1)
                    if let age = profile.age {
                        Text("\(age)")
                            .cuddleFont(size: 13, weight: .regular)
                            .foregroundStyle(.secondary)
                    }
                }

                if let occupation = profile.occupation {
                    Text(occupation)
                        .cuddleFont(size: 12, weight: .regular)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                // MARK: Action buttons
                HStack(spacing: 10) {
                    Button(action: onPass) {
                        Image(systemName: "xmark")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .foregroundStyle(.red)
                            .background(.red.opacity(0.1))
                            .clipShape(Capsule())
                    }
                    Button(action: onLikeBack) {
                        Image(systemName: "heart.fill")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .foregroundStyle(.white)
                            .background(appLinearGradient)
                            .clipShape(Capsule())
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 6)
            }
            .padding(12)
        }
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
    }
}
