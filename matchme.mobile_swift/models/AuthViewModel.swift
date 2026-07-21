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
    case undifined
    case authenticated
    case notAuthenticated
}

@Observable class AuthViewModel {
    var userSession: FirebaseAuth.User?
    var currentUser: User?

    var authState: AuthState = .undifined

    func startUp() {

        self.userSession = Auth.auth().currentUser

        Task {
            await fetchUser()
        }
    }

    //  Work on refining this function
    func listenToAuthStateChanges() {
        _ = Auth.auth().addStateDidChangeListener { auth, user in
            if self.userSession != nil {
                self.authState = .authenticated

                return
            }
            self.authState = user != nil ? .authenticated : .notAuthenticated
        }
    }

    func signIn(withEmail email: String, password: String) async throws {

    }

    func createUser(withEmail email: String, password: String, fullname: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user

            // Generate Stellar keypair and fund on testnet
            let stellarPublicKey: String?
            if let kp = try? StellarWalletService.shared.getOrCreateKeypair() {
                stellarPublicKey = kp.accountId
                try? await StellarWalletService.shared.fundTestnetAccount(publicKey: kp.accountId)
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
            print("DEBUG: failed to create user with error \(error.localizedDescription)")
        }
    }

    func signOut() {

    }

    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else { return }

        do {
            // Delete Firestore user document first
            try await Firestore
                .firestore()
                .collection("users")
                .document(user.uid)
                .delete()

            // Delete the Firebase Auth account
            try await user.delete()

            // Clear Stellar keypair from Keychain
            StellarWalletService.shared.clearKeypair()

            // Reset local state
            self.userSession = nil
            self.currentUser = nil
            self.authState = .notAuthenticated
        } catch {
            print("DEBUG: failed to delete account with error \(error.localizedDescription)")
            throw error
        }
    }

    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid
        else { return }

        guard
            let snapshot =
                try? await Firestore
                .firestore()
                .collection("users")
                .document(uid)
                .getDocument()
        else { return }

        self.currentUser = try? snapshot.data(as: User.self)
    }
}
