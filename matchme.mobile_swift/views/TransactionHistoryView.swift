//
//  TransactionHistoryView.swift
//  matchme.mobile_swift
//
//  ISS-025: Displays on-chain payment history fetched from Horizon
//  via StellarWalletService.transactionHistory(for:).
//  Linked from StellarWalletView.
//

import SwiftUI

struct TransactionHistoryView: View {

    let publicKey: String

    @State private var records: [StellarWalletService.PaymentRecord] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if isLoading {
                CuddleLoadingView(message: "Fetching transactions…")

            } else if let error = errorMessage {
                // Error state
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .resizable().scaledToFit().frame(width: 48)
                        .foregroundStyle(.orange)
                    Text(error)
                        .cuddleFont(size: 14, weight: .regular)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            } else if records.isEmpty {
                // Empty state
                VStack(spacing: 16) {
                    Image(systemName: "tray")
                        .resizable().scaledToFit().frame(width: 56)
                        .foregroundStyle(.gradientDark.opacity(0.4))
                    Text("No transactions yet")
                        .cuddleFont(size: 20, weight: .bold)
                    Text("Your on-chain payments will appear here.")
                        .cuddleFont(size: 14, weight: .regular)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(32)

            } else {
                // Transaction list
                List(records) { record in
                    TransactionRowView(record: record, currentPublicKey: publicKey)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Transaction History")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadHistory()
        }
    }

    private func loadHistory() async {
        isLoading = true
        errorMessage = nil
        records = await StellarWalletService.shared.transactionHistory(for: publicKey)
        isLoading = false
    }
}

// MARK: - Transaction Row

private struct TransactionRowView: View {

    let record: StellarWalletService.PaymentRecord
    let currentPublicKey: String

    private var isSent: Bool { record.direction == .sent }

    var body: some View {
        HStack(spacing: 14) {

            // Direction icon
            ZStack {
                Circle()
                    .fill(isSent ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
                    .frame(width: 44, height: 44)
                Image(systemName: isSent ? "arrow.up.right" : "arrow.down.left")
                    .foregroundStyle(isSent ? .red : .green)
                    .font(.system(size: 16, weight: .semibold))
            }

            // Counterparty + date
            VStack(alignment: .leading, spacing: 3) {
                Text(isSent ? "Sent" : "Received")
                    .cuddleFont(size: 15, weight: .bold)
                Text(shortKey(record.counterparty))
                    .cuddleFont(size: 12, weight: .regular)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Text(record.date, style: .relative)
                    .cuddleFont(size: 11, weight: .regular)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Amount
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(isSent ? "-" : "+")\(record.amount)")
                    .cuddleFont(size: 15, weight: .bold)
                    .foregroundStyle(isSent ? .red : .green)
                Text(record.assetCode)
                    .cuddleFont(size: 11, weight: .regular)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    /// Shortens a Stellar public key to G...XXXX format for display.
    private func shortKey(_ key: String) -> String {
        guard key.count > 8 else { return key }
        return "\(key.prefix(4))…\(key.suffix(4))"
    }
}
