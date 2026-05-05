//
//  TestView.swift
//  cuddleme.mobile_swift
//
//  Created by Gideon Adewuyi on 04/09/2024.
//

import SwiftUI

struct TestView: View {
    @State private var position: CGFloat? = 0
    var body: some View {
        ScrollView {
            LazyVStack {

                Button("Jump to Position...") {
                    position = 0
                }

                ForEach(0..<3) { index in

                    Rectangle()
                        .fill(.green.gradient)
                        .frame(height: 300)
                        .id(index)

                }
            }.background(
                GeometryReader { geometry -> Color in
                    DispatchQueue.main.async {
                        self.position = geometry.frame(in: .global).minY
                    }
                    return Color.clear
                }
            )
        }.onChange(of: position) {
            print(position?.rounded() ?? "Nothing to show")
        }
        .scrollPosition(id: $position)

    }
}

#Preview {
    TestView()
}


