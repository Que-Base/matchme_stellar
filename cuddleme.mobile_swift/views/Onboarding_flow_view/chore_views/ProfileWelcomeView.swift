//
//  ProfileWelcomeView.swift
//  cuddleme.mobile_swift
//
//  Created by Gideon Adewuyi on 07/09/2024.
//

import SwiftUI


struct ProfileWelcomeView: View {
  var body: some View {
    VStack {
      Image("logo_gradient")
        .padding()
        .background(.red, in: Circle())
        .padding(.bottom, 26)
      
      Text("Welcome to cuddle me")
        .cuddleFont(.Athletics, size: 24, weight: .bold)
      
      Text("Personalize your experience. Be honest so you can get the same in return. You can change this whenever you want.")
        .cuddleFont(size: 14)
        .multilineTextAlignment(.center)
      
      CuddlePointView()
      
    }.padding(.horizontal, 24)
  }
}

#Preview {
  ProfileWelcomeView()
}
