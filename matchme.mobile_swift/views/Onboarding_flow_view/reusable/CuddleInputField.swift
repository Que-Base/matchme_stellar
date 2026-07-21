//
//  cuddleInputField.swift
//  matchme.mobile_swift
//
//  Created by Gideon Adewuyi on 06/09/2024.
//

import SwiftUI

struct CuddleInputField: View {
    @Binding var input: String
    var label: LocalizedStringKey
    var fieldSet: LocalizedStringKey
    var isSecure: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .cuddleFont(size: 12)
                .foregroundStyle(.greyABAD)

            Group {
                if isSecure {
                    SecureField(fieldSet, text: $input)
                } else {
                    TextField(fieldSet, text: $input)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled(true)
                }
            }
            .padding(.vertical, 12)
            .padding(.leading, 14)
            .background(.greyABAD.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}
