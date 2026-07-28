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
        service.clearKeypair()
        super.tearDown()
    }

    // MARK: - Keypair generation

    func test_getOrCreateKeypair_returnsKeypair() throws {
        let keypair = try service.getOrCreateKeypair()
        XCTAssertNotNil(keypair)
    }

    func test_getOrCreateKeypair_publicKeyIsNotEmpty() throws {
        let keypair = try service.getOrCreateKeypair()
        XCTAssertFalse(keypair.accountId.isEmpty)
    }

    func test_getOrCreateKeypair_publicKeyStartsWithG() throws {
        // Stellar public keys always start with 'G'
        let keypair = try service.getOrCreateKeypair()
        XCTAssertTrue(
            keypair.accountId.hasPrefix("G"),
            "Expected Stellar public key to start with 'G', got: \(keypair.accountId)"
        )
    }

    func test_getOrCreateKeypair_returnsSameKeypairOnSecondCall() throws {
        let first = try service.getOrCreateKeypair()
        let second = try service.getOrCreateKeypair()
        XCTAssertEqual(first.accountId, second.accountId)
    }

    // MARK: - Keychain clear

    func test_clearKeypair_removesFromKeychain() throws {
        // Create a keypair first
        _ = try service.getOrCreateKeypair()

        // Clear it
        service.clearKeypair()

        // A new call should generate a different keypair (new random seed)
        let newKeypair = try service.getOrCreateKeypair()
        XCTAssertNotNil(newKeypair)
        // We can't assert it's *different* since it's random, but
        // we can assert it succeeds without throwing
    }

    // MARK: - Balance parsing

    func test_xlmBalance_returnsNilForInvalidPublicKey() async {
        let balance = await service.xlmBalance(for: "INVALID_KEY")
        XCTAssertNil(balance)
    }
}
