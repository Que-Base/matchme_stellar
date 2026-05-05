//
//  cuddleCircleProgressView.swift
//  cuddleme.mobile_swift
//
//  Created by Gideon Adewuyi on 30/08/2024.
//

import SwiftUI


struct CircularProfilePictureView: View {
  var profileModel: ProfileViewModel
	
	var body: some View {
    ZStack(alignment: .bottom) {
			
			Circle()
				.stroke(.progressLight, lineWidth: 5)
			
			Circle()
        .trim(from: 0, to: profileModel.profileSetupComplition)
				.stroke(appLinearGradient, style: StrokeStyle(lineWidth: 5, lineCap: .round))
				.rotationEffect(.degrees(90))
				.animation(.linear, value: profileModel.profileSetupComplition)
			
			Image(profileModel.profileImage)
				.resizable()
				.aspectRatio(0.9, contentMode: .fit)
				.clipShape(Circle())
			
      if profileModel.profileSetupComplition < 1.0 {
        Text("\((profileModel.profileSetupComplition * 100).formatted())%")
          .cuddleFont(size: 10, weight: .medium)
          .foregroundStyle(.white)
          .frame(height: 30.0)
          .padding(.horizontal, 12).padding(.vertical, 4.0)
          .background(appLinearGradient, in: Capsule())
          .offset(y: 15)
      }
			
		}.frame(maxWidth: 158, maxHeight: 148)
		
	}
}


