//
//  StellarWalletService.swift
//  matchme.mobile_swift
//
//  ISS-050: Converted from `class` singleton to `actor`.
//  All methods are now called with `await StellarWalletService.shared.method()`
//  which ensures thread-safe access to Keychain helpers and Horizon queries.
//

import Foundation
import Security
// MARK: - MATCH Asset Configuration (ISS-022a)

public struct MatchAssetConfig {
    /// Asset code for the MatchMe protocol token
    public static let code = "MATCH"
    
    /// Default testnet issuer account public key for MATCH tokens
    public static let defaultIssuerAccountId = "GBMATCHMEISSUERACCOUNTXLMSTELLARPUBLICKEY1234567890123"
}

// MARK: - Stellar Wallet Errors

public enum StellarWalletServiceError: LocalizedError {
    case keypairNotFound
    case invalidPublicKey(String)
    case accountNotFound(String)
    case insufficientBalance(required: String, available: String)
    case trustlineCreationFailed(String)
    case transactionFailed(String)

    public var errorDescription: String? {
        switch self {
        case .keypairNotFound:
            return "No Stellar keypair found in iOS Keychain."
        case .invalidPublicKey(let key):
            return "Invalid Stellar public key format: \(key)"
        case .accountNotFound(let key):
            return "Stellar account \(key) not found on ledger. Please fund account first."
        case .insufficientBalance(let required, let available):
            return "Insufficient balance: Required \(required), but available is \(available)."
        case .trustlineCreationFailed(let reason):
            return "Failed to establish trustline: \(reason)"
        case .transactionFailed(let reason):
            return "Transaction submission failed: \(reason)"
        }
    }
}

actor StellarWalletService {

    static let shared = StellarWalletService()
    private let sdk = StellarSDK.testNet()
    private let keychainSecretKey = "com.matchme.stellar.secretKey"

    // MARK: - Keypair

    /// Returns existing keypair from Keychain, or generates and stores a new one.
    func getOrCreateKeypair() throws -> KeyPair {
        if let secret = loadSecretFromKeychain(),
           let kp = try? KeyPair(secretSeed: secret) {
            return kp
        }
        let kp = try KeyPair.generateRandomKeyPair()
        try saveSecretToKeychain(kp.secretSeed)
        return kp
    }

    // MARK: - Testnet Funding

    /// Funds the account via Friendbot (testnet only).
    func fundTestnetAccount(publicKey: String) async throws {
        try await sdk.accounts.createTestAccount(accountId: publicKey)
    }

    // MARK: - Trustlines (ISS-022)

    /// Checks if the given account has an established trustline for the specified asset code and optional issuer.
    func hasTrustline(for publicKey: String, assetCode: String = MatchAssetConfig.code, issuerAccountId: String? = nil) async -> Bool {
        guard let accountDetails = try? await sdk.accounts.getAccountDetails(accountId: publicKey) else {
            return false
        }
        return accountDetails.balances.contains { balance in
            if balance.assetCode == assetCode {
                if let issuer = issuerAccountId {
                    return balance.assetIssuer == issuer
                }
                return true
            }
            return false
        }
    }

    /// Establishes a trustline for the MATCH token (or custom asset) if not already created.
    /// Returns the transaction hash on success.
    @discardableResult
    func addTrustline(
        assetCode: String = MatchAssetConfig.code,
        issuerAccountId: String = MatchAssetConfig.defaultIssuerAccountId,
        limit: Decimal? = nil
    ) async throws -> String {
        guard let keypair = try? getOrCreateKeypair() else {
            throw StellarWalletServiceError.keypairNotFound
        }

        // 1. Verify account exists on ledger
        guard let accountDetails = try? await sdk.accounts.getAccountDetails(accountId: keypair.accountId) else {
            throw StellarWalletServiceError.accountNotFound(keypair.accountId)
        }

        // 2. Check if trustline already exists (ISS-022e)
        if hasAlreadyEstablishedTrustline(accountDetails: accountDetails, assetCode: assetCode, issuerAccountId: issuerAccountId) {
            return "TRUSTLINE_ALREADY_EXISTS"
        }

        // 3. Construct Asset
        guard let issuerKeyPair = try? KeyPair(accountId: issuerAccountId),
              let asset = Asset(type: AssetType.ASSET_TYPE_CREDIT_ALPHANUM4, code: assetCode, issuer: issuerKeyPair) else {
            throw StellarWalletServiceError.invalidPublicKey(issuerAccountId)
        }

        // 4. Construct ChangeTrustOperation
        let changeTrustOp = ChangeTrustOperation(sourceAccount: nil, asset: asset, limit: limit)

        // 5. Create Transaction
        let transaction = try Transaction(sourceAccount: accountDetails, operations: [changeTrustOp], memo: Memo.none)
        try transaction.sign(keyPair: keypair, network: Network.testnet)

        // 6. Submit Transaction to Horizon
        let response = try await sdk.transactions.submitTransaction(transaction: transaction)
        if response.successful {
            return response.transactionHash
        } else {
            throw StellarWalletServiceError.transactionFailed("Submission rejected by Horizon")
        }
    }

    /// Ensures a trustline for MATCH asset exists for the user account, adding it if missing (ISS-022d).
    @discardableResult
    func ensureMatchTrustline(publicKey: String) async throws -> String? {
        let exists = await hasTrustline(for: publicKey, assetCode: MatchAssetConfig.code)
        if exists {
            return "TRUSTLINE_ALREADY_EXISTS"
        }
        return try await addTrustline(assetCode: MatchAssetConfig.code)
    }

    // MARK: - Payments & Transfers (ISS-023)

    /// Submits a Stellar PaymentOperation to transfer XLM or custom assets (MATCH) to a recipient address.
    /// - Parameters:
    ///   - destinationPublicKey: Recipient's Stellar Ed25519 public key.
    ///   - assetCode: Asset code to transfer ("XLM" for native, or "MATCH"). Default is "MATCH".
    ///   - issuerAccountId: Issuer public key if asset is a credit asset (defaults to MatchAssetConfig.defaultIssuerAccountId).
    ///   - amount: Amount to transfer as a Decimal value.
    ///   - memoText: Optional text memo attached to transaction.
    /// - Returns: The transaction hash on successful submission.
    @discardableResult
    func sendPayment(
        to destinationPublicKey: String,
        assetCode: String = MatchAssetConfig.code,
        issuerAccountId: String = MatchAssetConfig.defaultIssuerAccountId,
        amount: Decimal,
        memoText: String? = nil
    ) async throws -> String {
        // 1. Load sender keypair from Keychain (ISS-023b)
        guard let senderKeyPair = try? getOrCreateKeypair() else {
            throw StellarWalletServiceError.keypairNotFound
        }

        // 2. Validate destination keypair format (ISS-023f)
        guard let destinationKeyPair = try? KeyPair(accountId: destinationPublicKey) else {
            throw StellarWalletServiceError.invalidPublicKey(destinationPublicKey)
        }

        // 3. Fetch sender account details and sequence number from Horizon (ISS-023c)
        guard let senderAccount = try? await sdk.accounts.getAccountDetails(accountId: senderKeyPair.accountId) else {
            throw StellarWalletServiceError.accountNotFound(senderKeyPair.accountId)
        }

        // 4. Verify destination account exists on ledger (ISS-023f)
        guard let destinationAccount = try? await sdk.accounts.getAccountDetails(accountId: destinationPublicKey) else {
            throw StellarWalletServiceError.accountNotFound(destinationPublicKey)
        }

        // 5. Construct Asset (Native XLM vs Credit Asset) (ISS-023a)
        let asset: Asset
        if assetCode == "XLM" || assetCode == AssetTypeAsString.NATIVE {
            guard let nativeAsset = Asset(type: AssetType.ASSET_TYPE_NATIVE) else {
                throw StellarWalletServiceError.invalidPublicKey("NATIVE")
            }
            asset = nativeAsset
        } else {
            guard let issuerKeyPair = try? KeyPair(accountId: issuerAccountId),
                  let creditAsset = Asset(type: AssetType.ASSET_TYPE_CREDIT_ALPHANUM4, code: assetCode, issuer: issuerKeyPair) else {
                throw StellarWalletServiceError.invalidPublicKey(issuerAccountId)
            }
            // Check recipient has established trustline for credit asset
            let hasTrust = destinationAccount.balances.contains { b in
                b.assetCode == assetCode && b.assetIssuer == issuerAccountId
            }
            guard hasTrust else {
                throw StellarWalletServiceError.trustlineCreationFailed("Destination account does not have a trustline for \(assetCode)")
            }
            asset = creditAsset
        }

        // 6. Check sender balance (ISS-023f)
        let currentBalanceDecimal: Decimal
        if assetCode == "XLM" || assetCode == AssetTypeAsString.NATIVE {
            let balStr = senderAccount.balances.first { $0.assetType == AssetTypeAsString.NATIVE }?.balance ?? "0"
            currentBalanceDecimal = Decimal(string: balStr) ?? 0
        } else {
            let balStr = senderAccount.balances.first { $0.assetCode == assetCode && $0.assetIssuer == issuerAccountId }?.balance ?? "0"
            currentBalanceDecimal = Decimal(string: balStr) ?? 0
        }

        guard currentBalanceDecimal >= amount else {
            throw StellarWalletServiceError.insufficientBalance(
                required: "\(amount) \(assetCode)",
                available: "\(currentBalanceDecimal) \(assetCode)"
            )
        }

        // 7. Build PaymentOperation (ISS-023a)
        let paymentOp = PaymentOperation(sourceAccount: nil, destination: destinationKeyPair, asset: asset, amount: amount)

        // 8. Build & Sign Transaction Envelope (ISS-023b, ISS-023c)
        let memo = memoText != nil ? try? Memo.text(memoText!) : nil
        let transaction = try Transaction(sourceAccount: senderAccount, operations: [paymentOp], memo: memo ?? Memo.none)
        try transaction.sign(keyPair: senderKeyPair, network: Network.testnet)

        // 9. Submit to Horizon (ISS-023d, ISS-023e)
        let response = try await sdk.transactions.submitTransaction(transaction: transaction)
        if response.successful {
            return response.transactionHash
        } else {
            throw StellarWalletServiceError.transactionFailed("Payment submission rejected by Horizon network")
        }
    }

    private func hasAlreadyEstablishedTrustline(accountDetails: AccountResponse, assetCode: String, issuerAccountId: String) -> Bool {
        return accountDetails.balances.contains { balance in
            return balance.assetCode == assetCode && balance.assetIssuer == issuerAccountId
        }
    }

    // MARK: - Transaction History (ISS-025)

    /// Represents a single on-chain payment record for display in the history list.
    struct PaymentRecord: Identifiable {
        let id: String              // transaction hash
        let amount: String          // formatted amount string
        let assetCode: String       // "XLM" or "MATCH"
        let direction: Direction    // sent or received
        let counterparty: String    // the other account public key
        let date: Date

        enum Direction {
            case sent
            case received
        }
    }

    /// Fetches on-chain payment history for the given public key from Horizon.
    /// Returns up to `limit` records in descending chronological order.
    ///
    /// ISS-025 sub-tasks:
    ///   - Fetch payments from Horizon `payments` endpoint
    ///   - Map each operation into a `PaymentRecord`
    ///   - Determine direction (sent vs received) from senderPublicKey
    ///   - Handle both native XLM and MATCH credit asset payments
    func transactionHistory(
        for publicKey: String,
        limit: Int = 20
    ) async -> [PaymentRecord] {
        // 1. Query Horizon payments endpoint for the account
        guard let response = try? await sdk.payments.getPayments(
            forAccount: publicKey,
            from: nil,
            order: Order.descending,
            limit: limit,
            includeFailed: false,
            join: nil
        ) else {
            return []
        }

        // 2. Map each operation record to a PaymentRecord
        var records: [PaymentRecord] = []

        for record in response.records {
            // 3. Only process payment operations (ignore account creation etc.)
            guard let payment = record as? PaymentOperationResponse else { continue }

            // 4. Determine direction
            let direction: PaymentRecord.Direction = payment.sourceAccount == publicKey ? .sent : .received
            let counterparty = direction == .sent ? payment.to : payment.from

            // 5. Resolve asset code
            let assetCode: String
            if payment.assetType == AssetTypeAsString.NATIVE {
                assetCode = "XLM"
            } else {
                assetCode = payment.assetCode ?? "UNKNOWN"
            }

            // 6. Parse date from created_at ISO8601 string
            let date: Date
            if let createdAt = payment.createdAt {
                let formatter = ISO8601DateFormatter()
                date = formatter.date(from: createdAt) ?? Date()
            } else {
                date = Date()
            }

            records.append(PaymentRecord(
                id: payment.id ?? UUID().uuidString,
                amount: payment.amount,
                assetCode: assetCode,
                direction: direction,
                counterparty: counterparty,
                date: date
            ))
        }

        return records
    }

    // MARK: - Balance

    /// Returns the XLM balance for the given public key, or nil if account not found.
    func xlmBalance(for publicKey: String) async -> String? {
        guard let response = try? await sdk.accounts.getAccountDetails(accountId: publicKey) else {
            return nil
        }
        return response.balances
            .first { $0.assetType == AssetTypeAsString.NATIVE }
            .map { $0.balance }
    }

    /// Returns the MATCH token balance for the given public key, or nil if account or trustline is not found (ISS-024).
    func matchBalance(
        for publicKey: String,
        assetCode: String = MatchAssetConfig.code,
        issuerAccountId: String = MatchAssetConfig.defaultIssuerAccountId
    ) async -> String? {
        guard let response = try? await sdk.accounts.getAccountDetails(accountId: publicKey) else {
            return nil
        }
        return response.balances
            .first { $0.assetCode == assetCode && $0.assetIssuer == issuerAccountId }
            .map { $0.balance }
    }

    // MARK: - Keychain helpers

    private func saveSecretToKeychain(_ secret: String) throws {
        let data = Data(secret.utf8)
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: keychainSecretKey,
            kSecValueData: data,
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw NSError(
                domain: "StellarWallet",
                code: Int(status),
                userInfo: [NSLocalizedDescriptionKey: "Keychain write failed"]
            )
        }
    }

    /// Removes the stored secret seed from Keychain. Called on account deletion.
    func clearKeypair() {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: keychainSecretKey
        ]
        SecItemDelete(query as CFDictionary)
    }

    private func loadSecretFromKeychain() -> String? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: keychainSecretKey,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
