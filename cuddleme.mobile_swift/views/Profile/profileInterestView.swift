//
//  profileInterestView.swift
//  cuddleme.mobile_swift
//
//  Created by Gideon Adewuyi on 31/08/2024.
//

import SwiftUI

struct CuddleInterestView: View {
	@StateObject var viewModel = ChipsViewModel()
	var body: some View {
		VStack(alignment: .leading) {
			Text("Interests")
				.cuddleFont(.Athletics, size: 18, weight: .bold)
				.lineSpacing(24)
				.padding(.bottom, 8)
			
			CuddleChipContainerView(viewModel: viewModel)
		}
	}
}

