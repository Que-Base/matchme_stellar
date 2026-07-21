import SwiftUI
import SwiftfulRouting

struct ContentView: View {

    @Environment(AuthViewModel.self) private var authViewModel

    var body: some View {
        Group {
            RouterView { _ in
                switch authViewModel.authState {
                case .undifined:
                    // Auth state not yet resolved — show a neutral loading
                    // screen while the Firebase listener fires on startup.
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.white)
                case .authenticated:
                    if authViewModel.currentUser != nil {
                        DashboardView()
                    } else {
                        // Authenticated but user document still loading —
                        // stay on the loading screen until fetchUser() fills it.
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(.white)
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
