//
//  profileSetupView.swift
//  matchme.mobile_swift
//
//  Created by Gideon Adewuyi on 06/09/2024.
//
//  ISS-014: Wires form fields to Firestore and provides a completion
//  callback so the auth flow can navigate here after createUser().
//

import SwiftUI
import FirebaseFirestore

struct ProfileSetupView: View {

    @Environment(AuthViewModel.self) private var authViewModel

    @State private var textNameField: String = ""
    @State private var textJobField: String = ""
    @State private var textBioField: String = ""
    @State private var isSaving: Bool = false
    @State private var errorMessage: String?

    /// ISS-014a — called when setup completes so the caller can navigate away.
    var onComplete: (() -> Void)?

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {

                // Profile picture placeholder
                // TODO: ISS-013 — replace with photo picker
                CircularProfilePictureView(
                    profileModel: ProfileViewModel.setupInit()
                )
                .padding(.bottom, 32)

                // Full name
                CuddleInputField(
                    input: $textNameField,
                    label: "Full Name",
                    fieldSet: ""
                )
                .padding(.bottom, 24)

                // Job title
                CuddleInputField(
                    input: $textJobField,
                    label: "Job Title",
                    fieldSet: ""
                )
                .padding(.bottom, 24)

                // Bio
                CuddleInputField(
                    input: $textBioField,
                    label: "Bio",
                    fieldSet: ""
                )
                .padding(.bottom, 32)

                // TODO: ISS-014c — add interests selection step

                if let error = errorMessage {
                    Text(error)
                        .cuddleFont(size: 13, weight: .regular)
                        .foregroundStyle(.red)
                        .padding(.bottom, 12)
                }

                CuddleGradientButton(label: isSaving ? "Saving…" : "All good") {
                    Task { await saveProfile() }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
        }
        .navigationTitle("Set up your profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Pre-fill with existing user data if available
            if let user = authViewModel.currentUser {
                textNameField = user.fullname
                textJobField = user.occupation ?? ""
                textBioField = user.bio ?? ""
            }
        }
    }

    // MARK: - ISS-014b: Save to Firestore

    private func saveProfile() async {
        guard let uid = authViewModel.currentUser?.id else { return }
        guard !textNameField.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter your full name."
            return
        }

        isSaving = true
        errorMessage = nil

        do {
            try await Firestore.firestore()
                .collection("users")
                .document(uid)
                .updateData([
                    "fullname": textNameField,
                    "occupation": textJobField,
                    "bio": textBioField,
                    "profileSetupCompletion": computeCompletion()
                ])

            // Refresh local user object
            await authViewModel.fetchUser()
            onComplete?()

        } catch {
            errorMessage = error.localizedDescription
        }

        isSaving = false
    }

    // ISS-014d — derive a 0.0–1.0 completion score from filled fields
    private func computeCompletion() -> Double {
        let fields: [String] = [textNameField, textJobField, textBioField]
        let filled = fields.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.count
        // 3 basic fields + photo (not yet) = treat 3 fields as 0.75 max until ISS-013
        return min(Double(filled) / 4.0, 0.75)
    }
}

#Preview {
    NavigationStack {
        ProfileSetupView()
    }
}
