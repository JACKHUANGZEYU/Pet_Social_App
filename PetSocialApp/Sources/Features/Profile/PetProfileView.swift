import SwiftUI

struct CurrentPetProfileView: View {
    @StateObject private var viewModel: ProfileViewModel

    init(viewModel: ProfileViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        PetProfileView(viewModel: viewModel)
    }
}

struct PetProfileView: View {
    @EnvironmentObject private var container: AppContainer
    @StateObject private var viewModel: ProfileViewModel
    @State private var isShowingEditProfile = false

    init(viewModel: ProfileViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            if let pet = viewModel.petProfile {
                VStack(alignment: .leading, spacing: 20) {
                    header(for: pet)
                    stats
                    postSection
                }
                .padding(20)
            } else if viewModel.isLoading {
                ProgressView("Fetching profile...")
                    .padding(.top, 48)
            } else {
                EmptyStateCard(
                    title: "Profile unavailable",
                    message: "This pet profile could not be loaded right now.",
                    systemImage: "pawprint"
                )
                .padding(20)
            }
        }
        .background(container.theme.palette.appBackground.ignoresSafeArea())
        .navigationTitle(viewModel.isViewingCurrentPet ? "My Pet" : "Pet Profile")
        .task {
            await viewModel.loadProfile()
        }
        .onAppear {
            Task {
                await viewModel.loadProfile()
            }
        }
        .refreshable {
            await viewModel.loadProfile()
        }
        .sheet(isPresented: $isShowingEditProfile) {
            if let pet = viewModel.petProfile {
                NavigationStack {
                    EditPetProfileView(
                        viewModel: EditPetProfileViewModel(
                            profile: pet,
                            session: container.session,
                            repository: container.repository,
                            mediaStorage: container.mediaStorage,
                            aiService: container.aiService
                        ) { _ in
                            isShowingEditProfile = false
                            Task {
                                await viewModel.loadProfile()
                            }
                        }
                    )
                }
            }
        }
    }

    private func header(for pet: PetProfile) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                PetAvatarView(imageURL: pet.avatarURL, size: 92)

                VStack(alignment: .leading, spacing: 8) {
                    Text(pet.name)
                        .font(.system(size: 30, weight: .bold, design: .rounded))

                    Text(pet.handle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text("\(pet.petType.rawValue.capitalized) - \(pet.breed) - \(pet.age)y")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(.secondary)
                }
            }

            Text(pet.bio)
                .font(.body)

            PersonalityTagRow(tags: pet.personalityTags)

            if viewModel.isViewingCurrentPet {
                Button {
                    isShowingEditProfile = true
                } label: {
                    Label("Edit Profile", systemImage: "slider.horizontal.3")
                        .font(.headline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 0.17, green: 0.37, blue: 0.58))
            } else {
                Button {
                    viewModel.toggleFollow()
                } label: {
                    HStack {
                        if viewModel.isTogglingFollow {
                            ProgressView()
                        }

                        Text(viewModel.isFollowing ? "Following" : "Follow")
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(viewModel.isFollowing ? Color(red: 0.46, green: 0.58, blue: 0.42) : container.theme.palette.accent)
                .disabled(viewModel.isTogglingFollow)
            }
        }
    }

    private var stats: some View {
        HStack(spacing: 12) {
            ProfileStatCard(value: "\(viewModel.posts.count)", label: "Posts")
            ProfileStatCard(value: "\(viewModel.followerCount)", label: "Followers")
            ProfileStatCard(value: "\(viewModel.followingCount)", label: "Following")
        }
    }

    private var postSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Recent posts")
                .font(.headline)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Color(red: 0.74, green: 0.23, blue: 0.19))
            }

            if viewModel.posts.isEmpty {
                EmptyStateCard(
                    title: "No posts yet",
                    message: "This pet has not posted anything yet.",
                    systemImage: "text.bubble"
                )
            } else {
                ForEach(viewModel.posts) { post in
                    PostCardView(
                        post: post,
                        author: viewModel.petProfile,
                        canDelete: viewModel.isViewingCurrentPet,
                        isDeleting: viewModel.isDeletingPostID == post.id
                    ) {
                        viewModel.deletePost(post)
                    }
                }
            }
        }
    }
}
