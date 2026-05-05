//
//  AuthViewModel.swift
//  cuddleme.mobile_swift
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

            let _user = User(id: result.user.uid, fullname: fullname, email: email)

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

    func deleteAccount() {

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
