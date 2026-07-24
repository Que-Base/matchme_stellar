//
//  ExploreActionButtons.swift
//  matchme.mobile_swift
//
//  Created by Gideon Adewuyi on 24/07/2026.
//
//  ISS-008e: Stub — Pass, Super Like, Like action buttons.
//  TODO: animate button tap, wire to ViewModel actions.
//

import SwiftUI

struct ExploreActionButtons: View {

    let onPass: () -> Void
    let onSuperLike: () -> Void
    let onLike: () -> Void

    var body: some View {
        HStack(spacing: 24) {

            // Pass
            ActionButton(
                systemImage: "xmark",
                tint: .red,
                size: 52,
                action: onPass
            )

            // Super Like
            ActionButton(
                systemImage: "star.fill",
                tint: .blue,
                size: 44,
                action: onSuperLike
            )

            // Like
            ActionButton(
                systemImage: "heart.fill",
                tint: .green,
                size: 52,
                action: onLike
            )
        }
    }
}

// MARK: - Single circular button

private struct ActionButton: View {

    let systemImage: String
    let tint: Color
    let size: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .resizable()
                .scaledToFit()
                .frame(width: size * 0.42, height: size * 0.42)
                .foregroundStyle(tint)
                .frame(width: size, height: size)
                .background(.white)
                .clipShape(Circle())
                .shadow(color: tint.opacity(0.25), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ExploreActionButtons(
        onPass: {},
        onSuperLike: {},
        onLike: {}
    )
    .padding()
}
