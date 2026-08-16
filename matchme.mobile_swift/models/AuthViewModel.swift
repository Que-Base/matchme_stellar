//
//  AuthViewModel.swift
//  matchme.mobile_swift
//
//  Created by Gideon Adewuyi on 07/09/2024.
//

import Firebase
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

enum AuthState {
    case undefined
    case authenticated
    case notAuthenticated
}

@Observable class AuthViewModel {
    var userSession: FirebaseAuth.User?
    var currentUser: User?
    var authState: AuthState = .undefined

    /// ISS-036 — surface auth errors to the UI instead of only print()-ing them.
    var errorMessage: String?

    /// ISS-039 — true while fetchUser() or createUser() is in-flight.
    var isLoading: Bool = false

    /// ISS-065 — true when fetchUser has failed after all retries.
    /// ContentView observes this to show a retry prompt instead of
    /// staying on CuddleLoadingView indefinitely.
    var fetchUserFailed: Bool = false

    /// ISS-066 — true when Stellar wallet creation failed during signup or is missing
    var walletSetupFailed: Bool = false
    var isRetryingWalletSetup: Bool = false

    // Retain the listener handle so it is not immediately deallocated
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    private let maxFetchRetries = 3

    func startUp() {
        listenToAuthStateChanges()
    }

    func listenToAuthStateChanges() {
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [self] _, user in
            self.userSession = user
            self.authState = user != nil ? .authenticated : .notAuthenticated
            if user != nil {
                Task {
                    await self.fetchUser()
                    // ISS-026e — trigger daily login reward after user is fetched
                    if let user = self.currentUser,
                       let publicKey = user.stellarPublicKey {
                        await RewardService.shared.onDailyLogin(
                            userID: user.id,
                            publicKey: publicKey
                        )
                    }
                }
            } else {
                self.currentUser = nil
            }
        }
    }

    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            self.authState = .authenticated
            await fetchUser()
        } catch {
            self.errorMessage = error.localizedDescription
            print("DEBUG: failed to sign in with error \(error.localizedDescription)")
            throw error
        }
    }

    func createUser(withEmail email: String, password: String, fullname: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user

            // Generate Stellar keypair, fund on testnet, and establish MATCH trustline (ISS-022d, ISS-068)
            var stellarPublicKey: String? = nil
            do {
                let kp = try await StellarWalletService.shared.getOrCreateKeypair()
                stellarPublicKey = kp.accountId
                do {
                    try await StellarWalletService.shared.fundTestnetAccount(publicKey: kp.accountId)
                    try await StellarWalletService.shared.ensureMatchTrustline(publicKey: kp.accountId)
                } catch {
                    print("DEBUG: fundTestnetAccount / ensureMatchTrustline non-fatal error: \(error.localizedDescription)")
                }
            } catch let error as StellarWalletServiceError {
                print("DEBUG: Stellar keypair/Keychain failure in createUser() (ISS-068): \(error.localizedDescription)")
            } catch {
                print("DEBUG: Unexpected Stellar keypair error in createUser() (ISS-068): \(error.localizedDescription)")
            }
            
            if stellarPublicKey == nil {
                self.walletSetupFailed = true
            } else {
                self.walletSetupFailed = false
            }

            let _user = User(id: result.user.uid, fullname: fullname, email: email, stellarPublicKey: stellarPublicKey)

            let encodedUser = try Firestore.Encoder().encode(_user)

            try await Firestore
                .firestore()
                .collection("users")
                .document(_user.id)
                .setData(encodedUser)

            await fetchUser()

        } catch {
            self.errorMessage = error.localizedDescription
            print("DEBUG: failed to create user with error \(error.localizedDescription)")
            throw error
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            // ISS-067a — record error message so it is not swallowed silently
            self.errorMessage = error.localizedDescription
            print("DEBUG: failed to sign out with error \(error.localizedDescription)")
        }
        // ISS-067b — force-clear local auth state regardless of Firebase call result to ensure consistent unauthenticated UI
        self.userSession = nil
        self.currentUser = nil
        self.authState = .notAuthenticated
    }

    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else { return }
        let userUID = user.uid

        do {
            // Delete the Firebase Auth account FIRST (ISS-064a)
            // If this fails (e.g. requiresRecentLogin), the Firestore document
            // is not deleted, preventing orphaned Auth accounts.
            try await user.delete()

            // Delete Keychain Stellar seed (ISS-050)
            await StellarWalletService.shared.clearKeypair()

            // Auth deletion succeeded — now delete the Firestore user document (ISS-064b)
            try await Firestore
                .firestore()
                .collection("users")
                .document(userUID)
                .delete()

            // Reset local state
            self.userSession = nil
            self.currentUser = nil
            self.authState = .notAuthenticated
        } catch {
            self.errorMessage = error.localizedDescription
            print("DEBUG: failed to delete account with error \(error.localizedDescription)")
            throw error
        }
    }

    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        isLoading = true
        fetchUserFailed = false
        defer { isLoading = false }

        // ISS-065: retry up to maxFetchRetries times with exponential back-off
        // before giving up and setting fetchUserFailed = true so ContentView
        // can show a retry prompt instead of spinning indefinitely.
        for attempt in 1...maxFetchRetries {
            do {
                let snapshot = try await Firestore.firestore()
                    .collection("users")
                    .document(uid)
                    .getDocument()

                self.currentUser = try snapshot.data(as: User.self)
                return // success — exit the retry loop

            } catch {
                if attempt == maxFetchRetries {
                    // All retries exhausted
                    self.errorMessage = "Failed to load your profile. Tap retry."
                    self.fetchUserFailed = true
                } else {
                    // Brief back-off before next attempt (1s, 2s)
                    try? await Task.sleep(nanoseconds: UInt64(attempt) * 1_000_000_000)
                }
            }
        }
    }

    /// ISS-065: called by ContentView's retry button.
    func retryFetchUser() async {
        fetchUserFailed = false
        errorMessage = nil
        await fetchUser()
    }

    // MARK: - ISS-066: Wallet Repair / Retry

    /// Attempts to repair or create a Stellar wallet for the current user if missing or failed during signup.
    @discardableResult
    func retryWalletSetup() async throws -> String {
        guard let user = currentUser ?? (Auth.auth().currentUser.map { User(id: $0.uid, fullname: $0.displayName ?? "", email: $0.email ?? "") }) else {
            throw StellarWalletServiceError.keypairNotFound
        }

        isRetryingWalletSetup = true
        defer { isRetryingWalletSetup = false }

        let kp = try await StellarWalletService.shared.getOrCreateKeypair()
        try? await StellarWalletService.shared.fundTestnetAccount(publicKey: kp.accountId)
        try? await StellarWalletService.shared.ensureMatchTrustline(publicKey: kp.accountId)

        try await Firestore.firestore()
            .collection("users")
            .document(user.id)
            .updateData(["stellarPublicKey": kp.accountId])

        await fetchUser()
        self.walletSetupFailed = false
        return kp.accountId
    }
}
