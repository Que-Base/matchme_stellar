//
//  profileBioView.swift
//  cuddleme.mobile_swift
//
//  Created by Gideon Adewuyi on 30/08/2024.
//

import SwiftUI


struct ProfileBio: View {
	let bio: String
	var body: some View {
		VStack(alignment: .leading) {
			Text("Bio")
				.cuddleFont(.Athletics, size: 18, weight: .bold)
				.lineSpacing(24)
				.padding(.bottom, 8)
			Text(bio)
				.cuddleFont(size: 14)
				.tracking(0.14)
		}
	}
}

