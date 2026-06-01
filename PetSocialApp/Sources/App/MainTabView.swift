import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var container: AppContainer

    var body: some View {
        TabView {
            NavigationStack {
                FeedView(
                    viewModel: FeedViewModel(
                        session: container.session,
                        repository: container.repository
                    )
                )
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }

            NavigationStack {
                ExploreView(
                    viewModel: ExploreViewModel(
                        session: container.session,
                        repository: container.repository
                    )
                )
            }
            .tabItem {
                Label("Explore", systemImage: "safari.fill")
            }

            NavigationStack {
                CreatePostView(
                    viewModel: CreatePostViewModel(
                        session: container.session,
                        repository: container.repository,
                        mediaStorage: container.mediaStorage,
                        aiService: container.aiService
                    )
                )
            }
            .tabItem {
                Label("Post", systemImage: "plus.app.fill")
            }

            NavigationStack {
                PetAIStudioView(
                    viewModel: PetAIStudioViewModel(
                        session: container.session,
                        aiService: container.aiService
                    )
                )
            }
            .tabItem {
                Label("AI", systemImage: "sparkles")
            }

            NavigationStack {
                CurrentPetProfileView(
                    viewModel: ProfileViewModel(
                        session: container.session,
                        repository: container.repository
                    )
                )
            }
            .tabItem {
                Label("Profile", systemImage: "pawprint.fill")
            }

            NavigationStack {
                SettingsView(session: container.session)
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
        .tint(container.theme.palette.accent)
    }
}
