//
//  chipView.swift
//  cuddleme.mobile_swift
//
//  Created by Gideon Adewuyi on 30/08/2024.
//

import SwiftUI



struct CuddleChipContainerView: View {
	@ObservedObject var viewModel = ChipsViewModel()
	var body: some View {
		var width = CGFloat.zero
		var height = CGFloat.zero
		return GeometryReader { geo in
			ZStack(alignment: .topLeading, content: {
				ForEach(viewModel.chipArray) { data in
					CuddleChip(
						systemImage: data.systemImage,
						titleKey: data.titleKey
					)
					.padding(.bottom, 8)
					.padding(.trailing, 10)
					.alignmentGuide(.leading) { dimension in
						if (abs(width - dimension.width) > geo.size.width) {
							width = 0
							height -= dimension.height
						}
						let result = width
						if data.id == viewModel.chipArray.last!.id {
							width = 0
						} else {
							width -= dimension.width
						}
						return result
					}
					.alignmentGuide(.top) { dimension in
						let result = height
						if data.id == viewModel.chipArray.last!.id {
							height = 0
						}
						return result
					}
				}
			})
		}
	}
}

struct CuddleChip: View {
	let systemImage: String
	let titleKey: LocalizedStringKey
	
	var body: some View {
		HStack {
			Image(systemName: systemImage).font(.system(size: 10))
			Text(titleKey)
				.cuddleFont(size: 10, weight: .medium)
				.lineLimit(1)
			
		}
		.padding(.vertical, 8)
		.padding(.horizontal, 12)
		.background(.whiteF6)
		.clipShape(Capsule())
		.onTapGesture {
			
		}
	}
}

#Preview {
	CuddleChipContainerView()
}
