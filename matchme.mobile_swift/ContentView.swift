import SwiftUI
import SwiftfulRouting

struct ContentView: View {

    @Environment(AuthViewModel.self) private var authViewModel

    var body: some View {
        Group {
            RouterView { _ in
                if authViewModel.currentUser != nil {
                    DashboardView()
                } else {
                    switch authViewModel.authState {
                    case .undifined:
                        OnboardingView()
                    case .authenticated:
                        DashboardView()
                    case .notAuthenticated:
                        SignUpView()
                    }
                }
            }

        }
    }

}


#Preview {
    ContentView()
}
