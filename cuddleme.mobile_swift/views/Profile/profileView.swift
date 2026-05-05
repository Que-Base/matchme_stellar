//
//  profileView.swift
//  cuddleme.mobile_swift
//
//  Created by Gideon Adewuyi on 30/08/2024.
//

import SwiftUI
import SwiftfulRouting

struct ProfileView: View {
    @State private var activeTab1 = true
    @State private var cuddleProfileTab = "premium"

    let cuddleFeature: [String] = ["Feature_1 name", "Feature_2 name"]
  
  private let userProfile = ProfileViewModel.jostevModel(
    premiumAccount: true,
    profileSetupComplition: 0.8
  )

    var body: some View {
        RouterView { router in
            ScrollView {
                LazyVStack {
                  CuddleProfileInfoView(profile: userProfile)
                        .padding(.vertical, 32)

                    HStack(alignment: .bottom) {
                        Button(action: { activeTab1 = true }) {
                            VStack {
                                Text("Tab 1")
                                    .cuddleFont(
                                        size: 14,
                                        weight: activeTab1
                                            ? .medium
                                            : .regular
                                    )

                                    .foregroundStyle(
                                        activeTab1
                                            ? .black
                                            : .greyABAD
                                    )

                                Rectangle()
                                    .foregroundStyle(.black)
                                    .frame(maxHeight: activeTab1 ? 2 : 0)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())

                        Button(action: { activeTab1 = false }) {
                            VStack {
                                Text("Tab 2")
                                    .cuddleFont(
                                        size: 14,
                                        weight: !activeTab1
                                            ? .medium
                                            : .regular
                                    )
                                    .foregroundStyle(
                                        !activeTab1
                                            ? .black
                                            : .greyABAD
                                    )

                                Rectangle()
                                    .foregroundStyle(.black)
                                    .frame(maxHeight: activeTab1 ? 0 : 2)

                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .frame(height: 1, alignment: .bottom)
                            .foregroundStyle(Color(red: 0.94, green: 0.94, blue: 0.94))
                    }
                    .padding(.bottom, 24)
                    .padding(.horizontal, 24)

                    if activeTab1 {
                        VStack {
                          ProfileBio(bio: userProfile.bio)
                                .padding(.bottom, 16)

                            CuddleInterestView()
                                .padding(.bottom, 16 + 50)

                            ProfilePhotosView()
                                .padding(.bottom, 16)
                        }
                        .padding(.horizontal, 25)

                    } else {
                        ProfileTabView(spacing: 20)

                        LazyVStack(alignment: .leading) {
                            Text("Bio")
                                .cuddleFont(.Athletics, size: 18, weight: .bold)
                                .lineSpacing(24)
                                .padding(.bottom, 8)

                            ForEach(cuddleFeature, id: \.self) { index in
                                CuddleFeatures(featureName: index)
                            }
                        }.padding(.horizontal, 24)
                    }
                }
                .toolbar {
                    ProfileToolBar(
                        setting: {
                            router.showScreen(.push) { router in
                                SettingsView(router: router)
                                //.navigationBarBackButtonHidden(true)
                            }
                        },
                        notification: {}
                    )
                }
            }
            .scrollIndicators(.hidden)
        }
    }
}

struct CuddleFeatures: View {
    let featureName: String
    var body: some View {
        HStack {
            Text(featureName)
                .cuddleFont(size: 16)
                .foregroundStyle(.black)
            Spacer()
            Image("tick-gradient_icon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 18)
        }
        .padding(.vertical, 14)
    }
}

#Preview {
    ProfileView()
}

