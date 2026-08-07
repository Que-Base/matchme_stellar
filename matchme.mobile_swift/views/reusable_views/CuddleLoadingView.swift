//
//  CuddleLoadingView.swift
//  matchme.mobile_swift
//
//  Created by Gideon Adewuyi on 28/07/2026.
//
//  ISS-039: Reusable loading and shimmer components used across
//  all async-loading views (Explore, Profile, Wallet, etc.)
//

import SwiftUI

// MARK: - Full-screen loading overlay

struct CuddleLoadingView: View {
    var message: String = "Loading…"

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.4)
            Text(message)
                .cuddleFont(size: 14, weight: .regular)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white)
    }
}

// MARK: - Shimmer modifier

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: .clear, location: 0),
                            .init(color: .white.opacity(0.5), location: 0.4),
                            .init(color: .white.opacity(0.5), location: 0.6),
                            .init(color: .clear, location: 1)
                        ]),
                        startPoint: .init(x: phase, y: 0.5),
                        endPoint: .init(x: phase + 1, y: 0.5)
                    )
                    .frame(width: geo.size.width * 3)
                    .offset(x: -geo.size.width)
                }
                .clipped()
            )
            .onAppear {
                withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

// MARK: - Explore card skeleton

struct ExploreCardSkeleton: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color(.systemGray5))
            .shimmer()
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 8) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.systemGray4))
                        .frame(width: 160, height: 22)
                        .shimmer()
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.systemGray4))
                        .frame(width: 100, height: 14)
                        .shimmer()
                }
                .padding(20)
            }
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Fetch user failed / retry prompt (ISS-065)

/// Shown in ContentView when fetchUser() has exhausted all retries.
/// Prevents the user being stuck on an infinite loading screen.
struct FetchUserFailedView: View {
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "wifi.slash")
                .resizable()
                .scaledToFit()
                .frame(width: 56)
                .foregroundStyle(.gradientDark.opacity(0.5))

            Text("Couldn't load your profile")
                .cuddleFont(size: 20, weight: .bold)

            Text("Check your connection and try again.")
                .cuddleFont(size: 14, weight: .regular)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            CuddleGradientButton(label: "Retry", onCall: onRetry)
                .padding(.horizontal, 40)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white)
        .padding(32)
    }
}
