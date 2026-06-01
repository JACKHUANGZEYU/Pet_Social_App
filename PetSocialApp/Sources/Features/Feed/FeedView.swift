import SwiftUI

struct FeedView: View {
    @EnvironmentObject private var container: AppContainer
    @StateObject private var viewModel: FeedViewModel

    init(viewModel: FeedViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header

                if viewModel.isLoading {
                    ProgressView("Fetching tail-wagging updates...")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 32)
                } else if let errorMessage = viewModel.errorMessage {
                    EmptyStateCard(
                        title: "Feed paused",
                        message: errorMessage,
                        systemImage: "exclamationmark.bubble"
                    )
                } else if viewModel.posts.isEmpty {
                    EmptyStateCard(
                        title: "No posts yet",
                        message: "Follow a few pets or create the first post from your own profile.",
                        systemImage: "pawprint.circle"
                    )
                } else {
                    ForEach(viewModel.posts) { post in
                        PostCardView(
                            post: post,
                            author: viewModel.authorsByID[post.petID],
                            canDelete: viewModel.canManagePost(post),
                            isDeleting: viewModel.isDeletingPostID == post.id
                        ) {
                            viewModel.deletePost(post)
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(container.theme.palette.appBackground.ignoresSafeArea())
        .navigationTitle("Home Feed")
        .task {
            await viewModel.loadFeed()
        }
        .onAppear {
            Task {
                await viewModel.loadFeed()
            }
        }
        .refreshable {
            await viewModel.loadFeed()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your pet's world")
                .font(.caption.weight(.bold))
                .tracking(1.2)
                .foregroundStyle(.secondary)

            Text("See life through paws, whiskers, and dramatic park reports.")
                .font(.title2.weight(.bold))

            if let currentPet = container.session.currentPetProfile {
                HStack(spacing: 12) {
                    PetAvatarView(imageURL: currentPet.avatarURL, size: 54)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(currentPet.name)
                            .font(.headline)

                        Text(currentPet.handle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}
