//
//  StellarWalletView.swift
//  matchme.mobile_swift
//

import SwiftUI

struct StellarWalletView: View {
    let publicKey: String
    @State private var xlmBalance: String = "Loading..."
    @State private var matchBalance: String = "Loading..."

    var body: some View {
        // Wrapped in NavigationStack so the Transaction History NavigationLink
        // works correctly when this view is pushed via SwiftfulRouting (ISS-059)
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text("Stellar Wallet")
                            .font(.headline)
                        Spacer()
                        Text("Testnet")
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.blue.opacity(0.15))
                            .foregroundStyle(.blue)
                            .clipShape(Capsule())
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Public Key")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(publicKey)
                            .font(.caption2)
                            .monospaced()
                            .lineLimit(2)
                            .textSelection(.enabled)
                    }

                    Divider()

                    HStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("XLM Balance")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("\(xlmBalance) XLM")
                                .font(.title3)
                                .bold()
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text("MATCH Balance")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("\(matchBalance) MATCH")
                                .font(.title3)
                                .bold()
                                .foregroundStyle(.purple)
                        }
                    }

                    // ISS-025 / ISS-059 — NavigationLink now works inside NavigationStack
                    Divider()

                    NavigationLink {
                        TransactionHistoryView(publicKey: publicKey)
                    } label: {
                        HStack {
                            Image(systemName: "list.bullet.rectangle")
                                .foregroundStyle(.gradientDark)
                            Text("Transaction History")
                                .cuddleFont(size: 14, weight: .medium)
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                .padding()
            }
            .navigationTitle("Stellar Wallet")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            async let xlm = StellarWalletService.shared.xlmBalance(for: publicKey)
            async let match = StellarWalletService.shared.matchBalance(for: publicKey)
            let (fetchedXlm, fetchedMatch) = await (xlm, match)
            self.xlmBalance = fetchedXlm ?? "0"
            self.matchBalance = fetchedMatch ?? "0"
        }
    }
}
