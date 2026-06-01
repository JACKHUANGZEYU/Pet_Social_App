import SwiftUI

@main
struct PetSocialApp: App {
    @StateObject private var container = AppContainer.bootstrap()

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(container)
        }
    }
}
