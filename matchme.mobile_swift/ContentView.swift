import SwiftUI
import SwiftfulRouting

struct ContentView: View {

    @Environment(AuthViewModel.self) private var authViewModel

    var body: some View {
        Group {
            RouterView { _ in
                switch authViewModel.authState {
                case .undefined:
                    CuddleLoadingView()
                case .authenticated:
                    if authViewModel.currentUser != nil {
                        DashboardView()
                    } else if authViewModel.fetchUserFailed {
                        // ISS-065 — fetchUser exhausted retries; show retry prompt
                        // instead of spinning indefinitely.
                        FetchUserFailedView {
                            Task { await authViewModel.retryFetchUser() }
                        }
                    } else {
                        CuddleLoadingView(message: "Setting up your profile…")
                    }
                case .notAuthenticated:
                    OnboardingView()
                }
            }
        }
    }

}


#Preview {
    ContentView()
}
