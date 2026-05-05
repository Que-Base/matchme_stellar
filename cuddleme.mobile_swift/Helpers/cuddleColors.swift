//
//  cuddleColors.swift
//  cuddleme.mobile_swift
//
//  Created by Gideon Adewuyi on 29/08/2024.
//

import SwiftUI

let appLinearGradient = LinearGradient(
		colors: [.gradientDark, .gradientLight],
		startPoint: .leading,
		endPoint: .trailing
)

let appLinearGradientTop_Down = LinearGradient(
		colors: [.gradientDark, .gradientLight],
		startPoint: .bottom,
		endPoint: .top
)

let secondryAppLinearGradientTop_Down = LinearGradient(
		colors: [.secondryGradientDark, .secondryGradientLight],
		startPoint: .bottom,
		endPoint: .top
)

extension Color {
		static let appGradient = [Color("gradientDark"), Color("gradientLight")]
}
