//
//  OnboardingView.swift
//  matchme.mobile_swift
//
//  Created by Gideon Adewuyi on 28/08/2024.
//
//  ISS-044: Terms and Privacy Policy links now open in SFSafariViewController.
//

import SwiftUI
import SwiftfulRouting
import SafariServices

// MARK: - URLs (update to production URLs before App Store release)
private let termsURL   = URL(string: "https://matchme.app/terms")!
private let privacyURL = URL(string: "https://matchme.app/privacy")!

struct OnboardingView: View {
	@Environment(\.router) var router

	// ISS-044 — tracks which URL to open in the in-app browser
	@State private var activeURL: URL? = nil

	var body: some View {
		VStack {
			Image("logo_gradient_full")
				.padding(.bottom, 24)
				.padding(.top, 52)
			Text("Let's get started. Create your account")
				.cuddleFont()
				.padding(.bottom, 30)
			ZStack {
				Image("line")
					.aspectRatio(contentMode: .fill)
			}
			Text("lorem ipsim siet")
				.cuddleFont(.Athletics, size: 30.75, weight: .bold)
				.padding(.bottom, 60)

			CuddleGradientButton(label: "Sign up with Linkedin") {
				router.showScreen(.push) { _ in
					SignUpView()
						.navigationBarBackButtonHidden(true)
				}
			}
			.padding(.bottom, 32.0)

			HStack {
				Text("Have an account already?")
					.cuddleFont(size: 14)
					.foregroundStyle(.grey76)
				Button {
					router.showScreen(.push) { _ in
						SignInView()
							.navigationBarBackButtonHidden(true)
					}
				} label: {
					Text("Log in")
						.cuddleFont(size: 16, weight: .medium)
						.foregroundStyle(appLinearGradient)
						.underline()
				}
			}

			Spacer()

			// ISS-044 — wired to open in SFSafariViewController
			TextLinkBuilder(
				firstText: "By signing up you agree to our",
				secondText: "Terms and Conditions.",
				onCall: { activeURL = termsURL }
			)

			TextLinkBuilder(
				firstText: "Learn how we use your data in our",
				secondText: "Privacy Policy.",
				onCall: { activeURL = privacyURL }
			)

		}
		.padding(.horizontal, 24)
		.sheet(item: $activeURL) { url in
			SafariView(url: url)
				.ignoresSafeArea()
		}
	}
}

// MARK: - SafariView UIViewControllerRepresentable wrapper

struct SafariView: UIViewControllerRepresentable {
	let url: URL

	func makeUIViewController(context: Context) -> SFSafariViewController {
		SFSafariViewController(url: url)
	}

	func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

// MARK: - URL Identifiable conformance for .sheet(item:)

extension URL: @retroactive Identifiable {
	public var id: String { absoluteString }
}

// MARK: - TextLinkBuilder

struct TextLinkBuilder: View {
	let firstText: String
	let secondText: String
	let onCall: () -> Void

	var body: some View {
		HStack {
			Text(firstText)
				.cuddleFont(size: 14)
				.foregroundStyle(.grey76)
			Button(
				action: onCall,
				label: {
					Text(secondText)
						.cuddleFont(size: 12, weight: .medium)
						.foregroundStyle(.grey76)
						.underline()
				}
			)
		}
	}
}

#Preview {
	OnboardingView()
}
