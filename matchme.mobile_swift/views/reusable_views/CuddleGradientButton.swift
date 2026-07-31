//
//  CuddleGraidientButton.swift
//  matchme.mobile_swift
//
//  Created by Gideon Adewuyi on 07/09/2024.
//
//  ISS-045: Replaced UIScreen.main.bounds.width (deprecated iOS 16+)
//  with .frame(maxWidth: .infinity). Parent views control horizontal
//  padding via .padding(.horizontal, N).
//

import SwiftUI

struct CuddleGradientButton: View {
    let label: String
    let onCall: () -> Void

    var body: some View {
        Button(
            action: onCall,
            label: {
                Text(label)
                    .cuddleFont(size: 18, weight: .medium)
                    .padding(.vertical, 16)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
            }
        )
        .buttonStyle(PlainButtonStyle())
        .background(appLinearGradient)
        .clipShape(Capsule())
    }
}
