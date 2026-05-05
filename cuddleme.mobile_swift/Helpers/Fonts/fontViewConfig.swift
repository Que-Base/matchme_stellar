import Foundation
import SwiftUI

enum CuddleFonts: String {
		case GeneralSans = "General Sans Variable"
		case Athletics = "Athletics"
		case SFProRounded = "SF Pro Rounded"
}

extension Font {
		static let customFont: (CuddleFonts, CGFloat) -> Font = { fontType, size in
				switch fontType {
				case .GeneralSans:
						Font.custom(fontType.rawValue, size: size)
				case .Athletics:
						Font.custom(fontType.rawValue, size: size)
				case .SFProRounded:
						Font.custom(fontType.rawValue, size: size)
				}
		}
}

extension Text {
		func cuddleFont(
				_ fontFamily: CuddleFonts? = nil,
				size: CGFloat? = nil,
				relativeTo: Font.TextStyle? = nil,
				weight: Font.Weight? = nil
		) -> Text {
				let text = self.font(
						.customFont(
								fontFamily ?? .GeneralSans,
								size ?? 16
						)
				)

				return text.fontWeight(weight ?? .regular)
		}
}
