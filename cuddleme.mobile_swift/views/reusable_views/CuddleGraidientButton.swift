//
//  CuddleGraidientButton.swift
//  cuddleme.mobile_swift
//
//  Created by Gideon Adewuyi on 07/09/2024.
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
                    #if os(iOS)
                        .frame(maxWidth: UIScreen.main.bounds.width - 50)
                    #endif
            }
        )
        .buttonStyle(PlainButtonStyle())
        .background(appLinearGradient)
        .clipShape(Capsule())
    }
}
