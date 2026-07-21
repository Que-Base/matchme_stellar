//
//  SignInView.swift
//  matchme.mobile_swift
//
//  Created as part of ISS-004 fix.
//

import SwiftUI
import FirebaseAuth

struct SignInView: View {
    @Environment(AuthViewModel.self) private var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var textEmail: String = ""
    @State private var textPassword: String = ""
    @State private var errorMessage: String? = nil
    @State private var isLoading: Bool = false
    @State private var showForgotPasswordAlert: Bool = false
    @State private var forgotPasswordEmail: String = ""
    @State private var forgotPasswordConfirmation: String? = nil

    private var canSubmit: Bool {
        !textEmail.trimmingCharacters(in: .whitespaces).isEmpty &&
        !textPassword.isEmpty
    }

    var body: some View {
        VStack {
            Image("logo_gradient_full")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.bottom, 34)
                .padding(.top, 40)

            CuddleInputField(input: $textEmail, label: "Email", fieldSet: "")
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .padding(.bottom, 24)

            CuddleInputField(input: $textPassword, label: "Password", fieldSet: "", isSecure: true)
                .padding(.bottom, 8)

            // Forgot password
            HStack {
                Spacer()
                Button {
                    forgotPasswordEmail = textEmail
                    showForgotPasswordAlert = true
                } label: {
                    Text("Forgot password?")
                        .cuddleFont(size: 13, weight: .medium)
                        .foregroundStyle(appLinearGradient)
                }
            }
            .padding(.bottom, 16)

            // Inline error message
            if let error = errorMessage {
                Text(error)
                    .cuddleFont(size: 13)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
            }

            if let confirmation = forgotPasswordConfirmation {
                Text(confirmation)
                    .cuddleFont(size: 13)
                    .foregroundStyle(.green)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
            }

            Spacer()

            CuddleGradientButton(label: isLoading ? "Signing in…" : "Log in") {
                guard canSubmit else {
                    errorMessage = "Please enter your email and password."
                    return
                }
                signIn()
            }
            .disabled(!canSubmit || isLoading)
            .padding(.bottom, 16)

            // Back to sign up
            HStack {
                Text("Don't have an account?")
                    .cuddleFont(size: 14)
                    .foregroundStyle(.grey76)
                Button {
                    dismiss()
                } label: {
                    Text("Sign up")
                        .cuddleFont(size: 16, weight: .medium)
                        .foregroundStyle(appLinearGradient)
                        .underline()
                }
            }

        }
        .padding(.horizontal, 24)
        .alert("Reset password", isPresented: $showForgotPasswordAlert) {
            TextField("Email address", text: $forgotPasswordEmail)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
            Button("Send reset link") {
                sendPasswordReset(to: forgotPasswordEmail)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Enter your email address and we'll send you a reset link.")
        }
    }

    // MARK: - Actions

    private func signIn() {
        errorMessage = nil
        forgotPasswordConfirmation = nil
        isLoading = true
        Task {
            do {
                try await authViewModel.signIn(
                    withEmail: textEmail.trimmingCharacters(in: .whitespaces),
                    password: textPassword
                )
            } catch {
                errorMessage = friendlyError(error)
            }
            isLoading = false
        }
    }

    private func sendPasswordReset(to email: String) {
        let trimmed = email.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            errorMessage = "Enter your email address to reset your password."
            return
        }
        Task {
            do {
                try await Auth.auth().sendPasswordReset(withEmail: trimmed)
                forgotPasswordConfirmation = "Reset link sent to \(trimmed). Check your inbox."
            } catch {
                errorMessage = friendlyError(error)
            }
        }
    }

    /// Maps Firebase error codes to readable messages.
    private func friendlyError(_ error: Error) -> String {
        let code = AuthErrorCode(_nsError: error as NSError)
        switch code.code {
        case .wrongPassword, .invalidCredential:
            return "Incorrect email or password. Please try again."
        case .userNotFound:
            return "No account found with that email address."
        case .invalidEmail:
            return "Please enter a valid email address."
        case .userDisabled:
            return "This account has been disabled. Contact support."
        case .networkError:
            return "Network error. Check your connection and try again."
        default:
            return error.localizedDescription
        }
    }
}

#Preview {
    SignInView()
        .environment(AuthViewModel())
}
