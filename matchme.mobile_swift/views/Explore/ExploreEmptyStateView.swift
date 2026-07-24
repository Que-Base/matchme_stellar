//
//  ExploreEmptyStateView.swift
//  matchme.mobile_swift
//
//  Created by Gideon Adewuyi on 24/07/2026.
//
//  ISS-008f: Stub — shown when the profile queue is exhausted.
//  TODO: add "Check back later" refresh action.
//

import SwiftUI

struct ExploreEmptyStateView: View {

    let onRefresh: () -> Void

    var body: some View {
        VStack(spacing: 20) {

            Image(systemName: "person.2.slash")
                .resizable()
                .scaledToFit()
                .frame(width: 72)
                .foregroundStyle(.gradientDark.opacity(0.4))

            Text("No more profiles")
                .cuddleFont(size: 22, weight: .bold)
                .foregroundStyle(.primary)

            Text("You've seen everyone nearby.\nCheck back later for new people.")
                .cuddleFont(size: 15, weight: .regular)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            CuddleGradientButton(label: "Refresh", onCall: onRefresh)
                .padding(.top, 8)
        }
        .padding(32)
    }
}

#Preview {
    ExploreEmptyStateView(onRefresh: {})
}
