import Firebase
import SwiftUI
import SwiftfulRouting

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true

    }
}

@main
struct cuddleme_mobile_swiftApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @State private var authViewModel: AuthViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authViewModel)
                .onAppear {
                    authViewModel.startUp()
                }

        }
    }
}
