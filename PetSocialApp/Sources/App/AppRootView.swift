import SwiftUI

struct AppRootView: View {
    @EnvironmentObject private var container: AppContainer

    var body: some View {
        Group {
            if container.session.isLoading {
                ProgressView("Loading pet world...")
                    .tint(container.theme.palette.accent)
            } else if !container.session.isAuthenticated {
                NavigationStack {
                    AuthFlowView(viewModel: AuthViewModel(session: container.session))
                }
            } else if !container.session.hasCompletedOnboarding {
                NavigationStack {
                    OnboardingFlowView(
                        viewModel: PetOnboardingViewModel(
                            session: container.session,
                            repository: container.repository,
                            service: PetOnboardingService(mediaStorage: container.mediaStorage),
                            aiService: container.aiService
                        )
                    )
                }
            } else {
                MainTabView()
            }
        }
        .background(container.theme.palette.appBackground.ignoresSafeArea())
        .task {
            if container.session.isLoading {
                await container.session.restore()
            }
        }
    }
}
