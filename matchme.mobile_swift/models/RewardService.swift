//
//  RewardService.swift
//  matchme.mobile_swift
//
//  ISS-026: Maps app events → MATCH token earn/spend amounts and
//  executes the corresponding Stellar payment on the testnet.
//
//  Sub-tasks implemented:
//    ISS-026a — RewardService with event → MATCH amount mapping
//    ISS-026b — +50 MATCH when profile bio + photo both set
//    ISS-026c — +100 MATCH on first mutual match
//    ISS-026d — +10 MATCH when user receives a like
//    ISS-026e — +5 MATCH on daily login (tracked in Firestore)
//    ISS-026f — Deductions: super like (-20), profile boost (-100)
//    ISS-026g — Guard: all distributions checked against Firestore
//               reward log to prevent duplicate payouts
//
//  IMPORTANT: This client-side implementation is suitable for testnet.
//  For mainnet, distributions MUST be authorised by a Cloud Function
//  (server-side signing with the reserve wallet) to prevent spoofing.
//

import Foundation
import FirebaseFirestore

// MARK: - Reward Event

/// All events that trigger a MATCH token earn or spend.
enum RewardEvent {

    // ── Earn events ──────────────────────────────────────────────────

    /// ISS-026b — User sets both a bio and at least one photo.
    /// Triggered once per account lifetime.
    case profileCompleted

    /// ISS-026c — Two users have mutually liked each other.
    /// Triggered once per unique match pair.
    case firstMutualMatch(matchedUserID: String)

    /// ISS-026d — Another user liked the current user's profile.
    /// Triggered once per unique liker per day.
    case receivedLike(fromUserID: String)

    /// ISS-026e — User opens the app for the first time on a given calendar day.
    case dailyLogin

    // ── Spend events ─────────────────────────────────────────────────

    /// ISS-026f — User sent a super like (costs 20 MATCH).
    case superLikeSent(toUserID: String)

    /// ISS-026f — User purchased a profile boost (costs 100 MATCH).
    case profileBoostPurchased

    // MARK: MATCH amount

    /// Returns the signed MATCH delta for this event.
    /// Positive = earn, negative = spend.
    var matchDelta: Decimal {
        switch self {
        case .profileCompleted:        return 50
        case .firstMutualMatch:        return 100
        case .receivedLike:            return 10
        case .dailyLogin:              return 5
        case .superLikeSent:           return -20
        case .profileBoostPurchased:   return -100
        }
    }

    /// A stable string key used to de-duplicate rewards in Firestore.
    func deduplicationKey(for userID: String) -> String {
        switch self {
        case .profileCompleted:
            return "\(userID)/profileCompleted"
        case .firstMutualMatch(let matchedUserID):
            // Sort IDs so A→B and B→A produce the same key
            let pair = [userID, matchedUserID].sorted().joined(separator: "_")
            return "match/\(pair)"
        case .receivedLike(let fromUserID):
            // Allow one reward per liker per day
            let day = ISO8601DateFormatter().string(from: Date()).prefix(10)
            return "\(userID)/like/\(fromUserID)/\(day)"
        case .dailyLogin:
            let day = ISO8601DateFormatter().string(from: Date()).prefix(10)
            return "\(userID)/dailyLogin/\(day)"
        case .superLikeSent(let toUserID):
            return "\(userID)/superLike/\(toUserID)"
        case .profileBoostPurchased:
            let ts = Int(Date().timeIntervalSince1970)
            return "\(userID)/boost/\(ts)"
        }
    }
}

// MARK: - RewardService

/// Handles MATCH token earn/spend event processing.
/// All public methods are safe to call from async UI contexts.
@Observable
final class RewardService {

    static let shared = RewardService()

    private let db = Firestore.firestore()

    // MARK: - Public API

    /// Processes a reward event for the given user.
    /// - If the event has already been rewarded (de-duplication check), it is silently skipped.
    /// - On testnet: executes a Stellar payment from/to the reserve wallet.
    /// - Returns the transaction hash if a payment was made, or nil if skipped.
    @discardableResult
    func process(event: RewardEvent, for userID: String, userPublicKey: String) async -> String? {
        let delta = event.matchDelta
        let key = event.deduplicationKey(for: userID)

        // ISS-026g — de-duplication: skip if already recorded
        guard await !alreadyRewarded(key: key) else {
            return nil
        }

        do {
            let txHash: String

            if delta > 0 {
                // ── Earn: reserve wallet pays the user ───────────────
                // TODO (mainnet): this must be a Cloud Function call so
                // the reserve wallet secret never touches the client.
                txHash = try await distributeReward(
                    to: userPublicKey,
                    amount: delta,
                    memo: key
                )
            } else {
                // ── Spend: user pays the reserve wallet ──────────────
                txHash = try await chargeUser(
                    publicKey: userPublicKey,
                    amount: abs(delta),
                    memo: key
                )
            }

            // Record the reward so it cannot be triggered again
            await recordReward(key: key, txHash: txHash, userID: userID, event: event)
            return txHash

        } catch {
            // Log the failure but do not surface to user
            // (rewards are best-effort; app flow should not block on them)
            print("RewardService: failed to process \(key) — \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - Convenience entry points

    /// ISS-026b — Call after ProfileSetupView saves bio + photo.
    func onProfileCompleted(userID: String, publicKey: String) async {
        await process(event: .profileCompleted, for: userID, userPublicKey: publicKey)
    }

    /// ISS-026c — Call after a mutual match is detected in ExploreViewModel.
    func onMutualMatch(userID: String, matchedUserID: String, publicKey: String) async {
        await process(
            event: .firstMutualMatch(matchedUserID: matchedUserID),
            for: userID,
            userPublicKey: publicKey
        )
    }

    /// ISS-026d — Call when a like is written to Firestore in ExploreViewModel.
    func onReceivedLike(likedUserID: String, fromUserID: String, likedUserPublicKey: String) async {
        await process(
            event: .receivedLike(fromUserID: fromUserID),
            for: likedUserID,
            userPublicKey: likedUserPublicKey
        )
    }

    /// ISS-026e — Call from AuthViewModel.startUp() after auth resolves.
    func onDailyLogin(userID: String, publicKey: String) async {
        await process(event: .dailyLogin, for: userID, userPublicKey: publicKey)
    }

    /// ISS-026f — Call in ExploreViewModel.superLike() before removing the card.
    func onSuperLikeSent(userID: String, toUserID: String, publicKey: String) async {
        await process(
            event: .superLikeSent(toUserID: toUserID),
            for: userID,
            userPublicKey: publicKey
        )
    }

    /// ISS-026f — Call when user purchases a profile boost in SettingsView.
    func onProfileBoostPurchased(userID: String, publicKey: String) async {
        await process(event: .profileBoostPurchased, for: userID, userPublicKey: publicKey)
    }

    // MARK: - Private helpers

    /// ISS-026g — checks Firestore `rewardLog/{key}` for an existing record.
    private func alreadyRewarded(key: String) async -> Bool {
        let safeKey = key.replacingOccurrences(of: "/", with: "_")
        let doc = try? await db.collection("rewardLog").document(safeKey).getDocument()
        return doc?.exists ?? false
    }

    /// Persists a reward log entry to Firestore to prevent duplicate payouts.
    private func recordReward(key: String, txHash: String, userID: String, event: RewardEvent) async {
        let safeKey = key.replacingOccurrences(of: "/", with: "_")
        try? await db.collection("rewardLog").document(safeKey).setData([
            "userID": userID,
            "txHash": txHash,
            "amount": "\(event.matchDelta)",
            "timestamp": FieldValue.serverTimestamp()
        ])
    }

    /// Distributes MATCH from the reserve wallet to the user (ISS-056).
    ///
    /// - On mainnet: Executes a POST request to `StellarConfig.rewardDistributionURL`
    ///   where the transaction is signed server-side by a Cloud Function.
    /// - On testnet / DEBUG: Calls the Cloud Function if configured, or generates a
    ///   simulated testnet transaction reference so the user does not pay themselves.
    private func distributeReward(to publicKey: String, amount: Decimal, memo: String) async throws -> String {
        #if DEBUG
        if let cloudFunctionURL = StellarConfig.rewardDistributionURL {
            return try await callRewardCloudFunction(to: publicKey, amount: amount, memo: memo, url: cloudFunctionURL)
        } else {
            // Testnet simulation placeholder (ISS-056a/c):
            // Prevents invalid self-payment transactions while reserve Cloud Function is offline on testnet.
            let simulatedTxHash = "testnet_dist_\(UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(24))"
            print("RewardService (DEBUG testnet): Distributed \(amount) MATCH to \(publicKey) [memo: \(memo), tx: \(simulatedTxHash)]")
            return simulatedTxHash
        }
        #else
        guard let cloudFunctionURL = StellarConfig.rewardDistributionURL else {
            throw StellarWalletServiceError.trustlineCreationFailed("Production reward distribution Cloud Function URL is not configured.")
        }
        return try await callRewardCloudFunction(to: publicKey, amount: amount, memo: memo, url: cloudFunctionURL)
        #endif
    }

    /// Helper for server-side signed reward distributions (ISS-056b).
    private func callRewardCloudFunction(to publicKey: String, amount: Decimal, memo: String, url: URL) async throws -> String {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "to": publicKey,
            "amount": "\(amount)",
            "memo": String(memo.prefix(28))
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw StellarWalletServiceError.trustlineCreationFailed("Cloud Function reward distribution HTTP request failed")
        }

        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let txHash = json["txHash"] as? String {
            return txHash
        }
        throw StellarWalletServiceError.trustlineCreationFailed("Invalid JSON response from reward Cloud Function")
    }

    /// Charges the user's wallet by sending MATCH to the reserve wallet.
    private func chargeUser(publicKey: String, amount: Decimal, memo: String) async throws -> String {
        return try await StellarWalletService.shared.sendPayment(
            to: StellarConfig.reserveWalletPublicKey,
            assetCode: MatchAssetConfig.code,
            amount: amount,
            memoText: String(memo.prefix(28))
        )
    }
}
