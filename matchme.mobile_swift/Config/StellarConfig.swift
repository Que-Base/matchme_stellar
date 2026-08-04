//
//  StellarConfig.swift
//  matchme.mobile_swift
//
//  ISS-057: Centralises Stellar network configuration so the issuer key
//  and network target are easy to swap at build time (ISS-030, mainnet).
//
//  HOW TO SWITCH NETWORKS:
//  Change `current` to `.mainnet` and provide production values.
//  Never commit the issuer secret seed — it belongs in a Cloud Function.
//

import Foundation

enum StellarNetwork {
    case testnet
    case mainnet
}

struct StellarConfig {

    // MARK: - Active network

    /// Change to `.mainnet` when ISS-030 (mainnet switch) is implemented.
    static let current: StellarNetwork = .testnet

    // MARK: - MATCH Asset

    static var matchAssetCode: String { "MATCH" }

    /// Issuer public key for the MATCH token.
    /// Testnet issuer funded 2026-08-04 via Friendbot.
    /// Replace with production issuer key for mainnet (ISS-030).
    static var matchIssuerPublicKey: String {
        switch current {
        case .testnet:
            return "GDW6CBZZS7NLC5LTXGWTBBEUIRMEFBWBNT6NLU7ZXG24MMJMLZILSSXZ"
        case .mainnet:
            // TODO (ISS-030): return production issuer public key
            fatalError("Production MATCH issuer key not configured. Complete ISS-030 before switching to mainnet.")
        }
    }

    // MARK: - Reserve wallet

    /// Public key of the reserve wallet used for MATCH token distributions.
    /// The corresponding secret seed must NEVER be stored in the app.
    /// Distributions are signed server-side by a Cloud Function (ISS-056).
    static var reserveWalletPublicKey: String {
        switch current {
        case .testnet:
            // TODO (ISS-056): provision a separate reserve wallet
            // Using issuer as reserve for testnet only — NOT acceptable for mainnet.
            return matchIssuerPublicKey
        case .mainnet:
            fatalError("Production reserve wallet not configured. Complete ISS-056 before switching to mainnet.")
        }
    }

    // MARK: - Horizon

    static var horizonURL: String {
        switch current {
        case .testnet:  return "https://horizon-testnet.stellar.org"
        case .mainnet:  return "https://horizon.stellar.org"
        }
    }

    static var friendbotURL: String? {
        switch current {
        case .testnet:  return "https://friendbot.stellar.org"
        case .mainnet:  return nil // No Friendbot on mainnet
        }
    }
}
