//
//  customScrollView.swift
//  cuddleme.mobile_swift
//
//  Created by Gideon Adewuyi on 04/09/2024.
//

import SwiftUI

struct ProfileTabView: View {

    @State private var position: Int? = 0
    var spacing: CGFloat?
    var tabSpacing: CGFloat?
  
  

    private let tabView = [true, false]

    var body: some View {

        VStack(spacing: spacing ?? 0) {
            ScrollView(.horizontal) {
                LazyHStack(alignment: .top, spacing: tabSpacing ?? 0) {
                    ForEach(0..<2) { index in
                        CuddleTag(isPremium: tabView[index])
                            .frame(width: UIScreen.main.bounds.width - 48)
                            .id(index)
                    }
                }
                .padding(.horizontal, 24)
                .scrollTargetLayout()
            }
            .frame(maxHeight: 150)
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $position)

            CuddleTabSwitch_2(cuddleProfileTab: $position)
        }
    }
}

struct CuddleTag: View {

    var isPremium: Bool = true
    private var taged: String {
        isPremium ? "premium" : "plus"
    }

    var body: some View {
        VStack(spacing: 0) {

            HStack {
                Image("logo_white")
                    .resizable()
                    .aspectRatio(contentMode: .fit)

                Text("cuddle me")
                    .cuddleFont(.SFProRounded, size: 30, weight: .semibold)
                    .foregroundStyle(.white)
            }
            .frame(maxHeight: 22)

            Text(taged)
                .cuddleFont(.SFProRounded, size: 30, weight: .light)
                .foregroundStyle(.white)
                .padding(.bottom, 13)

            Text("Click here to upgrade to \(taged) so you can see who already liked you.")
                .cuddleFont(size: 14, weight: .medium)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 48)
        .padding(.vertical, 18)
        .background(
            isPremium
                ? appLinearGradientTop_Down
                : secondryAppLinearGradientTop_Down
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))

    }
}

struct CuddleTabSwitch_2: View {
    @Binding var cuddleProfileTab: Int?

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .frame(width: 8, height: 8)
                .foregroundStyle(getActiveTab().0)

            Circle()
                .frame(width: 8, height: 8)
                .foregroundStyle(getActiveTab().1)

        }
    }

    func getActiveTab() -> (Color, Color) {
        var toggleReturn: (firtToggle: Color, secondToggle: Color)

        var activeTabIndicator_1: Color {
            cuddleProfileTab == 0 ? .black : .grey76.opacity(0.5)
        }

        var activeTabIndicator_2: Color {
            cuddleProfileTab == 1 ? .black : .grey76.opacity(0.5)
        }

        toggleReturn.firtToggle = activeTabIndicator_1
        toggleReturn.secondToggle = activeTabIndicator_2

        return toggleReturn
    }

}

#Preview {
    ProfileTabView()
}
