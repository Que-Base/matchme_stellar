import SwiftUI
import SwiftfulRouting

struct ContentView: View {

    @Environment(AuthViewModel.self) private var authViewModel

    var body: some View {
        Group {
            RouterView { _ in
                switch authViewModel.authState {
                case .undifined:
                    CuddleLoadingView()
                case .authenticated:
                    if authViewModel.currentUser != nil {
                        DashboardView()
                    } else {
                        // Authenticated but user document still loading —
                        // stay on the loading screen until fetchUser() fills it.
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
