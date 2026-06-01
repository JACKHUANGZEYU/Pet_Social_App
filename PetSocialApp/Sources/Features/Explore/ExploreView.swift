import SwiftUI

struct ExploreView: View {
    @EnvironmentObject private var container: AppContainer
    @StateObject private var viewModel: ExploreViewModel

    init(viewModel: ExploreViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List {
            Section {
                ForEach(viewModel.pets) { pet in
                    NavigationLink {
                        PetProfileView(
                            viewModel: ProfileViewModel(
                                session: container.session,
                                repository: container.repository,
                                selectedPetID: pet.id
                            )
                        )
                    } label: {
                        HStack(spacing: 14) {
                            PetAvatarView(imageURL: pet.avatarURL, size: 54)

                            VStack(alignment: .leading, spacing: 6) {
                                Text(pet.name)
                                    .font(.headline)

                                Text(pet.handle)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)

                                Text(pet.bio)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            } header: {
                Text("Discover pets")
            }
        }
        .scrollContentBackground(.hidden)
        .background(container.theme.palette.appBackground)
        .navigationTitle("Explore")
        .searchable(text: $viewModel.query, prompt: "Search pet name or pet ID")
        .task {
            await viewModel.loadExplore()
        }
        .onAppear {
            Task {
                await viewModel.loadExplore()
            }
        }
        .onChange(of: viewModel.query) { _, _ in
            viewModel.scheduleSearch()
        }
        .refreshable {
            await viewModel.loadExplore()
        }
        .overlay {
            if let errorMessage = viewModel.errorMessage {
                EmptyStateCard(
                    title: "Explore paused",
                    message: errorMessage,
                    systemImage: "exclamationmark.bubble"
                )
                .padding(24)
            } else if !viewModel.isLoading && viewModel.pets.isEmpty {
                EmptyStateCard(
                    title: "No pets found",
                    message: "Try another name, handle, or check back after more pets join.",
                    systemImage: "magnifyingglass"
                )
                .padding(24)
            }
        }
    }
}
