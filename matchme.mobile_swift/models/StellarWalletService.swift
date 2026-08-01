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

    private func hasAlreadyEstablishedTrustline(accountDetails: AccountResponse, assetCode: String, issuerAccountId: String) -> Bool {
        return accountDetails.balances.contains { balance in
            return balance.assetCode == assetCode && balance.assetIssuer == issuerAccountId
        }
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
