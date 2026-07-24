//
//  ExploreCardView.swift
//  matchme.mobile_swift
//
//  Created by Gideon Adewuyi on 24/07/2026.
//
//  ISS-008d: Stub — shows profile photo, name, age, occupation, interests.
//  TODO: replace AsyncImage placeholder with real photo URL (ISS-013).
//

import SwiftUI

struct ExploreCardView: View {

    let profile: ExploreProfile

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottomLeading) {

                // MARK: Photo
                // TODO: load from profile.photoURL via AsyncImage (ISS-013)
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
                                    colors: [.gradientDark.opacity(0.4), .gradientLight.opacity(0.4)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80)
                                    .foregroundStyle(.white.opacity(0.5))
                            )
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .clipped()

                // MARK: Gradient overlay
                LinearGradient(
                    colors: [.clear, .black.opacity(0.75)],
                    startPoint: .center,
                    endPoint: .bottom
                )

                // MARK: Profile info
                VStack(alignment: .leading, spacing: 6) {

                    // Name + age
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(profile.fullname)
                            .cuddleFont(size: 26, weight: .bold)
                            .foregroundStyle(.white)

                        if let age = profile.age {
                            Text("\(age)")
                                .cuddleFont(size: 22, weight: .medium)
                                .foregroundStyle(.white.opacity(0.9))
                        }
                    }

                    // Occupation
                    if let occupation = profile.occupation {
                        Text(occupation)
                            .cuddleFont(size: 15, weight: .regular)
                            .foregroundStyle(.white.opacity(0.85))
                    }

                    // Interests
                    if !profile.interests.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(profile.interests.prefix(5), id: \.self) { interest in
                                    Text(interest)
                                        .cuddleFont(size: 12, weight: .medium)
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(.white.opacity(0.2))
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    ExploreCardView(profile: ExploreProfile(
        id: "preview",
        fullname: "Amara Osei",
        age: 26,
        occupation: "UX Designer",
        interests: ["Travel", "Music", "Coffee", "Hiking"],
        photoURL: nil
    ))
    .frame(width: 340, height: 480)
    .padding()
}
