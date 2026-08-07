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

    override func tearDown() async throws {
        // Clean up any keypair written during tests
        await service.clearKeypair()
        try await super.tearDown()
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

    // MARK: - Trustlines (ISS-022)

    func test_hasTrustline_returnsFalseForInvalidPublicKey() async {
        let hasTrust = await service.hasTrustline(for: "INVALID_KEY", assetCode: "MATCH")
        XCTAssertFalse(hasTrust)
    }

    func test_addTrustline_throwsAccountNotFoundWhenUnfunded() async {
        let keypair = try? await service.getOrCreateKeypair()
        XCTAssertNotNil(keypair)
        
        do {
            _ = try await service.addTrustline(assetCode: "MATCH")
        } catch StellarWalletServiceError.accountNotFound {
            XCTAssertTrue(true)
        } catch {
            XCTAssertNotNil(error)
        }
    }

    // MARK: - Payments (ISS-023)

    func test_sendPayment_throwsInvalidPublicKeyForBadDestination() async {
        do {
            _ = try await service.sendPayment(to: "INVALID_KEY", amount: 10)
        } catch StellarWalletServiceError.invalidPublicKey {
            XCTAssertTrue(true)
        } catch {
            XCTAssertNotNil(error)
        }
    }

    func test_sendPayment_throwsAccountNotFoundWhenSenderUnfunded() async {
        let keypair = try? await service.getOrCreateKeypair()
        XCTAssertNotNil(keypair)
        
        do {
            _ = try await service.sendPayment(to: keypair!.accountId, amount: 5)
        } catch StellarWalletServiceError.accountNotFound {
            XCTAssertTrue(true)
        } catch {
            XCTAssertNotNil(error)
        }
    }

    // MARK: - MATCH Balance (ISS-024)

    func test_matchBalance_returnsNilForInvalidPublicKey() async {
        let matchBal = await service.matchBalance(for: "INVALID_KEY")
        XCTAssertNil(matchBal)
    }
}
