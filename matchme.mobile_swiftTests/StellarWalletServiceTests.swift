//
//  StellarWalletServiceTests.swift
//  matchme.mobile_swiftTests
//
//  ISS-041: Unit tests for StellarWalletService —
//  keypair generation, Keychain read/write, clearKeypair.
//

import XCTest
@testable import matchme_mobile_swift

final class StellarWalletServiceTests: XCTestCase {

    let service = StellarWalletService.shared

    override func tearDown() {
        // Clean up any keypair written during tests
        Task { await service.clearKeypair() }
        super.tearDown()
    }

    // MARK: - Keypair generation

    func test_getOrCreateKeypair_returnsKeypair() async throws {
        let keypair = try await service.getOrCreateKeypair()
        XCTAssertNotNil(keypair)
    }

    func test_getOrCreateKeypair_publicKeyIsNotEmpty() async throws {
        let keypair = try await service.getOrCreateKeypair()
        XCTAssertFalse(keypair.accountId.isEmpty)
    }

    func test_getOrCreateKeypair_publicKeyStartsWithG() async throws {
        // Stellar public keys always start with 'G'
        let keypair = try await service.getOrCreateKeypair()
        XCTAssertTrue(
            keypair.accountId.hasPrefix("G"),
            "Expected Stellar public key to start with 'G', got: \(keypair.accountId)"
        )
    }

    func test_getOrCreateKeypair_returnsSameKeypairOnSecondCall() async throws {
        let first = try await service.getOrCreateKeypair()
        let second = try await service.getOrCreateKeypair()
        XCTAssertEqual(first.accountId, second.accountId)
    }

    // MARK: - Keychain clear

    func test_clearKeypair_removesFromKeychain() async throws {
        // Create a keypair first
        _ = try await service.getOrCreateKeypair()
        // Clear it
        await service.clearKeypair()
        // A new call should succeed (generates fresh keypair)
        let newKeypair = try await service.getOrCreateKeypair()
        XCTAssertNotNil(newKeypair)
    }

    // MARK: - Balance parsing

    func test_xlmBalance_returnsNilForInvalidPublicKey() async {
        let balance = await service.xlmBalance(for: "INVALID_KEY")
        XCTAssertNil(balance)
    }
}
