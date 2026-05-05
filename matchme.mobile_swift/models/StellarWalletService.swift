//
//  StellarWalletService.swift
//  matchme.mobile_swift
//

import Foundation
import Security
import stellarsdk

class StellarWalletService {

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
            throw NSError(domain: "StellarWallet", code: Int(status), userInfo: [NSLocalizedDescriptionKey: "Keychain write failed"])
        }
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
