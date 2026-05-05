//
//  StellarWalletView.swift
//  matchme.mobile_swift
//

import SwiftUI

struct StellarWalletView: View {
    let publicKey: String
    @State private var balance: String = "Loading..."

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Stellar Wallet")
                .font(.headline)

            VStack(alignment: .leading, spacing: 6) {
                Text("Public Key")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(publicKey)
                    .font(.caption2)
                    .monospaced()
                    .lineLimit(2)
                    .textSelection(.enabled)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("XLM Balance")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(balance) XLM")
                    .font(.title3)
                    .bold()
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .task {
            balance = await StellarWalletService.shared.xlmBalance(for: publicKey) ?? "—"
        }
    }
}
