//
//  AuthViewModelTests.swift
//  matchme.mobile_swiftTests
//
//  ISS-041: Unit tests for AuthViewModel state transitions.
//
//  HOW TO ADD THE TEST TARGET IN XCODE:
//  1. File → New → Target → Unit Testing Bundle
//  2. Name it "matchme.mobile_swiftTests"
//  3. Add this file to the new target
//  4. Run with Cmd+U
//

import XCTest
@testable import matchme_mobile_swift

@MainActor
final class AuthViewModelTests: XCTestCase {

    // MARK: - AuthState transitions

    func test_initialAuthState_isUndefined() {
        let vm = AuthViewModel()
        XCTAssertEqual(vm.authState, .undefined)
    }

    func test_initialCurrentUser_isNil() {
        let vm = AuthViewModel()
        XCTAssertNil(vm.currentUser)
    }

    func test_initialUserSession_isNil() {
        let vm = AuthViewModel()
        XCTAssertNil(vm.userSession)
    }

    func test_initialErrorMessage_isNil() {
        let vm = AuthViewModel()
        XCTAssertNil(vm.errorMessage)
    }

    func test_initialIsLoading_isFalse() {
        let vm = AuthViewModel()
        XCTAssertFalse(vm.isLoading)
    }

    // MARK: - signOut resets state

    func test_signOut_resetsLocalState() {
        let vm = AuthViewModel()
        // Manually set authenticated state to simulate a signed-in session
        vm.authState = .authenticated
        vm.currentUser = User(
            id: "test-uid",
            fullname: "Test User",
            email: "test@example.com"
        )

        vm.signOut()

        XCTAssertNil(vm.currentUser)
        XCTAssertNil(vm.userSession)
        XCTAssertEqual(vm.authState, .notAuthenticated)
    }

    func test_signOut_forceClearsLocalSessionState() {
        let vm = AuthViewModel()
        vm.authState = .authenticated
        vm.userSession = nil // local mismatch state
        vm.currentUser = User(id: "uid_99", fullname: "Alex", email: "alex@example.com")

        vm.signOut()

        XCTAssertNil(vm.currentUser)
        XCTAssertNil(vm.userSession)
        XCTAssertEqual(vm.authState, .notAuthenticated)
    }

    // MARK: - Wallet Setup / Repair (ISS-066)

    func test_initialWalletSetupFailed_isFalse() {
        let vm = AuthViewModel()
        XCTAssertFalse(vm.walletSetupFailed)
    }

    func test_initialIsRetryingWalletSetup_isFalse() {
        let vm = AuthViewModel()
        XCTAssertFalse(vm.isRetryingWalletSetup)
    }
}
