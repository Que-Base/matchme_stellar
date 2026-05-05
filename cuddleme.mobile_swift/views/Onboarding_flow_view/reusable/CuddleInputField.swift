//
//  cuddleInputField.swift
//  cuddleme.mobile_swift
//
//  Created by Gideon Adewuyi on 06/09/2024.
//

import SwiftUI

struct CuddleInputField: View {
    @Binding var input: String
    var label: LocalizedStringKey
    var fieldSet: LocalizedStringKey
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .cuddleFont(size: 12)
                .foregroundStyle(.greyABAD)

            TextField(fieldSet, text: $input)
                .padding(.vertical, 12)
                .padding(.leading, 14)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled(true)
                .background(.greyABAD.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .onSubmit {
                    if label == "" && fieldSet != "" {
                        //            label = fieldSet
                        //            on submit use the field value for submition
                    }
                }
        }
    }
}
