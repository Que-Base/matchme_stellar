//
//  exploreView.swift
//  matchme.mobile_swift
//
//  Created by Gideon Adewuyi on 30/08/2024.
//
//  ISS-008: Replaces Text("Explore view") placeholder with a full stub:
//  card stack, action buttons, empty state, and loading indicator.
//  TODO (ISS-008b/c): add drag gesture recogniser for swipe-to-like/pass.
//

import SwiftUI
import SwiftfulRouting

struct ExploreView: View {

    @Environment(\.router) var router
    @Environment(AuthViewModel.self) private var authViewModel

    @State private var viewModel = ExploreViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // MARK: Header
                HStack {
                    Text("Explore")
                        .cuddleFont(size: 28, weight: .bold)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)

                // MARK: Content
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()

                } else if viewModel.profiles.isEmpty {
                    Spacer()
                    ExploreEmptyStateView {
                        Task {
                            await viewModel.fetchProfiles(
                                currentUserID: authViewModel.currentUser?.id ?? ""
                            )
                        }
                    }
                    Spacer()

                } else {
                    // MARK: Card stack
                    // TODO (ISS-008b/c): wrap in ZStack with drag gesture
                    ZStack {
                        ForEach(viewModel.profiles) { profile in
                            ExploreCardView(profile: profile)
                                .padding(.horizontal, 20)
                        }
                    }
                    .frame(maxHeight: .infinity)

                    // MARK: Action buttons
                    if let topProfile = viewModel.profiles.last {
                        ExploreActionButtons(
                            onPass: {
                                viewModel.pass(
                                    profile: topProfile,
                                    currentUserID: authViewModel.currentUser?.id ?? ""
                                )
                            },
                            onSuperLike: {
                                viewModel.superLike(
                                    profile: topProfile,
                                    currentUserID: authViewModel.currentUser?.id ?? ""
                                )
                            },
                            onLike: {
                                viewModel.like(
                                    profile: topProfile,
                                    currentUserID: authViewModel.currentUser?.id ?? ""
                                )
                            }
                        )
                        .padding(.vertical, 24)
                    }
                }
            }
            .task {
                await viewModel.fetchProfiles(
                    currentUserID: authViewModel.currentUser?.id ?? ""
                )
            }
        }
    }
}
