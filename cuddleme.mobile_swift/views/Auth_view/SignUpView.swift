//
//  SignUpView.swift
//  cuddleme.mobile_swift
//
//  Created by Gideon Adewuyi on 07/09/2024.
//

import SwiftUI

struct SignUpView: View {
    @Environment(AuthViewModel.self) private var authViewModel: AuthViewModel

    @State private var textEmail: String = ""
    @State private var textFullname: String = ""
    @State private var textPassword: String = ""
    @State private var textConfirmPassword: String = ""

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

            CuddleInputField(input: $textPassword, label: "Password", fieldSet: "")

            CuddleInputField(input: $textConfirmPassword, label: "Confirm Password", fieldSet: "")

            Spacer()
          

            CuddleGradientButton(label: "Sign Up") {
              Task {
                try await authViewModel.createUser(
                  withEmail: textEmail,
                  password: textPassword,
                  fullname: textFullname
                )

              }
            }
        }.padding(.horizontal, 24)
    }
}

#Preview {
    SignUpView()
}
