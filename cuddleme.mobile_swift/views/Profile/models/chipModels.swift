//
//  chipModels.swift
//  cuddleme.mobile_swift
//
//  Created by Gideon Adewuyi on 30/08/2024.
//

import SwiftUI

struct ChipModel: Identifiable {
		let id = UUID()
		let systemImage: String
		let titleKey: LocalizedStringKey
}

class ChipsViewModel: ObservableObject{
	
		@Published var chipArray: [ChipModel] = [
				ChipModel(systemImage: "heart.circle", titleKey: "Heart"),
				ChipModel(systemImage: "folder.circle", titleKey: "Folder"),
				ChipModel(systemImage: "pencil.and.outline", titleKey: "Pen"),
				ChipModel(systemImage: "book.circle", titleKey: "Book"),
				ChipModel(systemImage: "paperplane.circle", titleKey: "Paper Plain"),
				ChipModel(systemImage: "opticaldiscdrive", titleKey: "Optical Drive"),
				ChipModel(systemImage: "doc.circle", titleKey: "Documents"),
		]
}
