//
//  likeView.swift
//  matchme.mobile_swift
//
//  Created by Gideon Adewuyi on 30/08/2024.
//
//  ISS-009: Replaces Xcode placeholder with a structured stub —
//  grid of profiles that liked the current user, with like-back / pass actions.
//

import SwiftUI
import SwiftfulRouting

struct LikeView: View {

    @Environment(\.router) var router
    @Environment(AuthViewModel.self) private var authViewModel

    @State private var viewModel = LikesViewModel()

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // MARK: Header
                HStack {
                    Text("Likes")
                        .cuddleFont(size: 28, weight: .bold)
                    Spacer()
                    // Badge count
                    if !viewModel.profiles.isEmpty {
                        Text("\(viewModel.profiles.count)")
                            .cuddleFont(size: 13, weight: .bold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(appLinearGradient)
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)

                // MARK: Content
                if viewModel.isLoading {
                    Spacer()
                    CuddleLoadingView()
                    Spacer()

                } else if viewModel.profiles.isEmpty {
                    Spacer()
                    LikesEmptyStateView()
                    Spacer()

                } else {
                    // ISS-009b — grid of liked-by cards
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(viewModel.profiles) { profile in
                                LikeCardView(
                                    profile: profile,
                                    onLikeBack: {
                                        viewModel.likeBack(
                                            profile: profile,
                                            currentUserID: authViewModel.currentUser?.id ?? "",
                                            userPublicKey: authViewModel.currentUser?.stellarPublicKey
                                        )
                                    },
                                    onPass: {
                                        viewModel.pass(
                                            profile: profile,
                                            currentUserID: authViewModel.currentUser?.id ?? ""
                                        )
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    }
                }
            }
            .task {
                await viewModel.fetchLikes(
                    currentUserID: authViewModel.currentUser?.id ?? ""
                )
            }
        }
    }
}

// MARK: - Empty state

private struct LikesEmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.slash")
                .resizable()
                .scaledToFit()
                .frame(width: 64)
                .foregroundStyle(.gradientDark.opacity(0.4))

            Text("No likes yet")
                .cuddleFont(size: 22, weight: .bold)

            Text("When someone likes your profile\nthey'll appear here.")
                .cuddleFont(size: 15, weight: .regular)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
    }
}

#Preview {
    LikeView()
}
