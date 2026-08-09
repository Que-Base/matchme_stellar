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

            // Generate Stellar keypair, fund on testnet, and establish MATCH trustline (ISS-022d)
            let stellarPublicKey: String?
            if let kp = try? await StellarWalletService.shared.getOrCreateKeypair() {
                stellarPublicKey = kp.accountId
                try? await StellarWalletService.shared.fundTestnetAccount(publicKey: kp.accountId)
                try? await StellarWalletService.shared.ensureMatchTrustline(publicKey: kp.accountId)
            } else {
                stellarPublicKey = nil
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
            self.userSession = nil
            self.currentUser = nil
            self.authState = .notAuthenticated
        } catch {
            print("DEBUG: failed to sign out with error \(error.localizedDescription)")
        }
    }

    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else { return }
        let userUID = user.uid

        do {
            // Delete the Firebase Auth account FIRST (ISS-064a)
            // If this fails (e.g. requiresRecentLogin), the Firestore document remains intact
            // and no orphaned Auth record is left.
            try await user.delete()

            // Delete Firestore user document second
            try? await Firestore
                .firestore()
                .collection("users")
                .document(userUID)
                .delete()

            // Clear Stellar keypair from Keychain
            await StellarWalletService.shared.clearKeypair()

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
}
