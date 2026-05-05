//
//  profileSetupView.swift
//  cuddleme.mobile_swift
//
//  Created by Gideon Adewuyi on 06/09/2024.
//

import SwiftUI

struct ProfileSetupView: View {
    @State var textNameField: String = ""
    @State var textJobField: String = ""
    @State private var selectedFlavor: Flavor = .chocolate

    enum Flavor: String, CaseIterable, Identifiable {
        case chocolate, vanilla, strawberry
        var id: Self { self }
    }

    /// Creates the first profile view model

    var profileModel: ProfileViewModel = ProfileViewModel.jostevModel(
        premiumAccount: true,
        profileSetupComplition: 0.1
    )

    var body: some View {
        VStack {
            CircularProfilePictureView(profileModel: profileModel)
                .padding(.bottom, 32)

            CuddleInputField(input: $textNameField, label: "Full Name", fieldSet: "")
                .padding(.bottom, 24)

            CuddleInputField(input: $textJobField, label: "Job Title", fieldSet: "")

            Spacer()

            CuddleGradientButton(label: "All good") {}
        }.padding(.horizontal, 24)
    }
}

#Preview {
    ProfileSetupView()
}
