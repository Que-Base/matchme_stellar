//
//  SignUpView.swift
//  matchme.mobile_swift
//
//  Created by Gideon Adewuyi on 07/09/2024.
//
//  ISS-034: password fields use isSecure: true (SecureField)
//  ISS-035: confirm password validated before createUser is called
//  ISS-036: errors from authViewModel.errorMessage shown inline
//

import SwiftUI
import FirebaseAuth

struct SignUpView: View {

    @Environment(AuthViewModel.self) private var authViewModel: AuthViewModel

    @State private var textEmail: String = ""
    @State private var textFullname: String = ""
    @State private var textPassword: String = ""
    @State private var textConfirmPassword: String = ""
    @State private var isLoading: Bool = false
    @State private var localError: String? = nil

    // ISS-035 — passwords must match and meet minimum length
    private var passwordsMatch: Bool {
        textPassword == textConfirmPassword
    }
    private var passwordLongEnough: Bool {
        textPassword.count >= 6
    }
    private var canSubmit: Bool {
        !textFullname.trimmingCharacters(in: .whitespaces).isEmpty &&
        !textEmail.trimmingCharacters(in: .whitespaces).isEmpty &&
        passwordLongEnough &&
        passwordsMatch &&
        !isLoading
    }

    /// Combined error — prefer local validation over ViewModel error
    private var displayError: String? {
        localError ?? authViewModel.errorMessage
    }

    var body: some View {
        VStack {

            Image("logo_gradient_full")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.bottom, 34)
                .padding(.top, 40)

            CuddleInputField(input: $textFullname, label: "Full Name", fieldSet: "")
                .padding(.bottom, 24)

            CuddleInputField(input: $textEmail, label: "Email", fieldSet: "")
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)

            // ISS-034 — SecureField via isSecure: true
            CuddleInputField(input: $textPassword, label: "Password", fieldSet: "", isSecure: true)

            CuddleInputField(input: $textConfirmPassword, label: "Confirm Password", fieldSet: "", isSecure: true)

            // ISS-035 — live password mismatch hint
            if !textConfirmPassword.isEmpty && !passwordsMatch {
                Text("Passwords don't match.")
                    .cuddleFont(size: 12, weight: .regular)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 4)
            }

            // ISS-036 — inline error from ViewModel or local validation
            if let error = displayError {
                Text(error)
                    .cuddleFont(size: 13, weight: .regular)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
            }

            Spacer()

            CuddleGradientButton(label: isLoading ? "Creating account…" : "Sign Up") {
                signUp()
            }
            .disabled(!canSubmit)

        }
        .padding(.horizontal, 24)
    }

    // MARK: - Actions

    private func signUp() {
        localError = nil
        authViewModel.errorMessage = nil

        // ISS-035 — guard before calling Firebase
        guard passwordLongEnough else {
            localError = "Password must be at least 6 characters."
            return
        }
        guard passwordsMatch else {
            localError = "Passwords don't match. Please re-enter."
            return
        }

        isLoading = true
        Task {
            do {
                try await authViewModel.createUser(
                    withEmail: textEmail.trimmingCharacters(in: .whitespaces),
                    password: textPassword,
                    fullname: textFullname.trimmingCharacters(in: .whitespaces)
                )
            } catch {
                // ISS-036 — authViewModel.errorMessage already set inside createUser;
                // map to a friendly string here as a fallback.
                if authViewModel.errorMessage == nil {
                    authViewModel.errorMessage = friendlyError(error)
                }
            }
            isLoading = false
        }
    }

    /// Maps Firebase error codes to readable messages.
    private func friendlyError(_ error: Error) -> String {
        let code = AuthErrorCode(_nsError: error as NSError)
        switch code.code {
        case .emailAlreadyInUse:
            return "An account with that email already exists."
        case .invalidEmail:
            return "Please enter a valid email address."
        case .weakPassword:
            return "Password is too weak. Use at least 6 characters."
        case .networkError:
            return "Network error. Check your connection and try again."
        default:
            return error.localizedDescription
        }
    }
}

#Preview {
    SignUpView()
        .environment(AuthViewModel())
}
