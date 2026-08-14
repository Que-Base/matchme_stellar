//
//  settingsView.swift
//  matchme.mobile_swift
//
//  Created by Gideon Adewuyi on 31/08/2024.
//
//  ISS-011: Replaces single-item stub with a full settings screen.
//  Sections: Account, Wallet, Privacy, Notifications, Legal.
//

import SwiftUI
import SwiftfulRouting

struct SettingsView: View {

    let router: AnyRouter

    @Environment(AuthViewModel.self) private var authViewModel

    // MARK: - Local state

    /// Controls the sign-out confirmation alert
    @State private var showSignOutAlert = false
    /// Controls the delete account confirmation alert
    @State private var showDeleteAlert = false
    /// ISS-064c — error message when account deletion fails
    @State private var deleteError: String? = nil
    /// ISS-064c — controls account deletion failure alert
    @State private var showDeleteErrorAlert = false
    /// ISS-058 / ISS-066 — shown when user has no Stellar wallet yet
    @State private var showNoWalletAlert = false
    @State private var isRepairingWallet = false
    @State private var walletRepairError: String? = nil
    @State private var showWalletRepairErrorAlert = false
    /// ISS-011c — notification toggle (stub, not yet wired to UNUserNotificationCenter)
    @State private var notificationsEnabled = true
    /// ISS-011d — profile visibility toggle (stub, not yet persisted to Firestore)
    @State private var profileVisible = true

    var body: some View {
        NavigationStack {
            List {

                // MARK: Account
                Section("Account") {

                    // ISS-011e — Connect social media (stub destination)
                    SettingsRow(icon: "link", label: "Connect social media") {
                        // TODO: wire to OAuth flow
                    }

                // ISS-058 / ISS-066 — pass stellarPublicKey from currentUser; handle nil (no wallet yet)
                SettingsRow(
                    icon: "wallet.pass",
                    label: authViewModel.currentUser?.stellarPublicKey != nil ? "Stellar Wallet" : "Set Up Stellar Wallet"
                ) {
                    if let publicKey = authViewModel.currentUser?.stellarPublicKey {
                        router.showScreen(.push) { _ in
                            StellarWalletView(publicKey: publicKey)
                        }
                    } else {
                        showNoWalletAlert = true
                    }
                }
                }

                // MARK: Privacy
                Section("Privacy") {

                    Toggle(isOn: $profileVisible) {
                        SettingsLabel(icon: "eye", label: "Show my profile")
                    }
                    // TODO: persist profileVisible to Firestore users/{uid}

                    SettingsRow(icon: "location", label: "Location & distance") {
                        // TODO: navigate to location settings screen
                    }
                }

                // MARK: Notifications
                Section("Notifications") {
                    Toggle(isOn: $notificationsEnabled) {
                        SettingsLabel(icon: "bell", label: "Push notifications")
                    }
                    // TODO: wire to UNUserNotificationCenter.requestAuthorization
                }

                // MARK: Legal
                Section("Legal") {

                    // ISS-011g — Terms of Service
                    SettingsRow(icon: "doc.text", label: "Terms of Service") {
                        // TODO: open URL in SafariView (ISS-044)
                    }

                    // ISS-011g — Privacy Policy
                    SettingsRow(icon: "hand.raised", label: "Privacy Policy") {
                        // TODO: open URL in SafariView (ISS-044)
                    }

                    // ISS-011g — App version
                    HStack {
                        SettingsLabel(icon: "info.circle", label: "Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—")
                            .cuddleFont(size: 14, weight: .regular)
                            .foregroundStyle(.secondary)
                    }
                }

                // MARK: Danger zone
                Section {

                    // ISS-011a — Sign out
                    Button {
                        showSignOutAlert = true
                    } label: {
                        SettingsLabel(icon: "arrow.backward.circle", label: "Sign out")
                            .foregroundStyle(.orange)
                    }

                    // ISS-011b — Delete account
                    Button {
                        showDeleteAlert = true
                    } label: {
                        SettingsLabel(icon: "trash", label: "Delete account")
                            .foregroundStyle(.red)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)

            // MARK: Sign out alert
            .alert("Sign out?", isPresented: $showSignOutAlert) {
                Button("Sign out", role: .destructive) {
                    authViewModel.signOut()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("You will be returned to the login screen.")
            }

            // MARK: Delete account alert
            .alert("Delete account?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    Task {
                        do {
                            try await authViewModel.deleteAccount()
                        } catch {
                            deleteError = error.localizedDescription
                            showDeleteErrorAlert = true
                        }
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This is permanent. Your profile, matches, and Stellar wallet will be removed from this device. This cannot be undone.")
            }

            // MARK: Delete error alert (ISS-064c)
            .alert("Account Deletion Failed", isPresented: $showDeleteErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(deleteError ?? "An error occurred while deleting your account. If you signed in a long time ago, please sign out and sign back in before trying again.")
            }

            // MARK: No wallet alert / Setup action (ISS-058 / ISS-066)
            .alert("Set Up Stellar Wallet", isPresented: $showNoWalletAlert) {
                Button("Create Wallet") {
                    Task {
                        isRepairingWallet = true
                        do {
                            let publicKey = try await authViewModel.retryWalletSetup()
                            router.showScreen(.push) { _ in
                                StellarWalletView(publicKey: publicKey)
                            }
                        } catch {
                            walletRepairError = error.localizedDescription
                            showWalletRepairErrorAlert = true
                        }
                        isRepairingWallet = false
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Your account doesn't have a Stellar wallet configured yet. Tap 'Create Wallet' to generate your keypair, fund your testnet account, and enable MATCH rewards.")
            }

            // MARK: Wallet repair error alert (ISS-066)
            .alert("Wallet Setup Failed", isPresented: $showWalletRepairErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(walletRepairError ?? "An error occurred while creating your Stellar wallet. Please try again.")
            }
        }
        .padding(.horizontal, 0)
    }
}

// MARK: - Reusable row helpers

/// Tappable row with a chevron
private struct SettingsRow: View {
    let icon: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                SettingsLabel(icon: icon, label: label)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Icon + label used in both rows and toggles
private struct SettingsLabel: View {
    let icon: String
    let label: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 22)
                .foregroundStyle(.gradientDark)
            Text(label)
                .cuddleFont(size: 16, weight: .regular)
                .foregroundStyle(.primary)
        }
    }
}

#Preview {
    RouterView { router in
        SettingsView(router: router)
    }
}
