//
//  profilePhotosView.swift
//  cuddleme.mobile_swift
//
//  Created by Gideon Adewuyi on 01/09/2024.
//

import SwiftUI

struct ProfilePhotosView: View {
		private let image = ["mock_cat", "mock_cat"]
		var body: some View {
				VStack(alignment: .leading) {
						Text("Photos")
								.cuddleFont(.Athletics, size: 18, weight: .bold)
								.lineSpacing(24)
								.padding(.bottom, 8)

						HStack(spacing: 15) {
							CuddleImage(imagePath: image.first!)
							CuddleImage(imagePath: image.last!)
						}
				}
		}
}

struct CuddleImage: View {
		let imagePath: String
		var body: some View {
				Image(imagePath)
						.resizable()
						.aspectRatio(contentMode: .fill)
						.frame(width: 165, height: 212, alignment: .center)
						.clipShape(RoundedRectangle(cornerRadius: 14))

		}
}

#Preview {
		ProfilePhotosView()
}
