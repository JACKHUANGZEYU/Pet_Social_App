import PhotosUI
import SwiftUI
import UIKit

struct CreatePostView: View {
    @EnvironmentObject private var container: AppContainer
    @StateObject private var viewModel: CreatePostViewModel
    @State private var selectedPostImageItem: PhotosPickerItem?

    init(viewModel: CreatePostViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Post as your pet")
                    .font(.largeTitle.weight(.bold))

                if let pet = container.session.currentPetProfile {
                    HStack(spacing: 12) {
                        PetAvatarView(imageURL: pet.avatarURL, size: 52)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(pet.name)
                                .font(.headline)

                            Text("Speaking as \(pet.handle)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 14) {
                    Text("Caption")
                        .font(.headline)

                    Button {
                        viewModel.generateAICaptions()
                    } label: {
                        HStack {
                            if viewModel.isGeneratingAI {
                                ProgressView()
                            }

                            Label("AI Suggest Captions", systemImage: "sparkles")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(Color(red: 0.14, green: 0.33, blue: 0.27))
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color(red: 0.89, green: 0.97, blue: 0.91))
                    )
                    .disabled(viewModel.isGeneratingAI)

                    TextField(
                        "What is your pet thinking right now?",
                        text: $viewModel.text,
                        axis: .vertical
                    )
                    .lineLimit(5, reservesSpace: true)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.white.opacity(0.95))
                    )

                    if !viewModel.aiCaptions.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("AI caption ideas")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.secondary)

                            ForEach(viewModel.aiCaptions, id: \.self) { caption in
                                Button {
                                    viewModel.applyAICaption(caption)
                                } label: {
                                    Text(caption)
                                        .font(.footnote.weight(.medium))
                                        .foregroundStyle(Color(red: 0.16, green: 0.12, blue: 0.10))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .fill(Color.white.opacity(0.92))
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    Text("Image URL")
                        .font(.headline)

                    TextField("https://...", text: $viewModel.imageURL)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color.white.opacity(0.95))
                        )
                    .onChange(of: viewModel.imageURL) { _, _ in
                        viewModel.remoteImageURLDidChange()
                    }

                    PhotosPicker(selection: $selectedPostImageItem, matching: .images) {
                        Label("Choose From Photos", systemImage: "photo.stack")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(Color(red: 0.98, green: 0.92, blue: 0.86))
                            )
                    }
                    .buttonStyle(.plain)

                    Text("In live Supabase mode, the app will import this image into pet media storage before publishing the post.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    if let previewImage = pickedPreviewImage {
                        previewImage
                            .resizable()
                            .scaledToFill()
                            .frame(height: 220)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    } else if let previewURL = URL(string: viewModel.imageURL), !viewModel.imageURL.isEmpty {
                        AsyncImage(url: previewURL) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(Color.white.opacity(0.8))
                                .overlay {
                                    ProgressView()
                                }
                        }
                        .frame(height: 220)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    }

                    if viewModel.pickedImageAsset != nil {
                        Button("Use URL Instead") {
                            selectedPostImageItem = nil
                            viewModel.applyPickedImageAsset(nil)
                        }
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color(red: 0.90, green: 0.40, blue: 0.17))
                    }
                }

                if let statusMessage = viewModel.statusMessage {
                    Text(statusMessage)
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(Color(red: 0.17, green: 0.37, blue: 0.58))
                }

                Button(action: viewModel.submitPost) {
                    HStack {
                        if viewModel.isPosting {
                            ProgressView()
                                .tint(.white)
                        }

                        Text("Publish Post")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color(red: 0.90, green: 0.40, blue: 0.17))
                )
                .disabled(viewModel.isPosting)
            }
            .padding(24)
        }
        .background(container.theme.palette.appBackground.ignoresSafeArea())
        .navigationTitle("Create Post")
        .onChange(of: selectedPostImageItem) { _, newItem in
            guard let newItem else { return }
            Task {
                await loadPostAsset(from: newItem)
            }
        }
    }

    private var pickedPreviewImage: Image? {
        guard let data = viewModel.pickedImageAsset?.data,
              let uiImage = UIImage(data: data) else {
            return nil
        }

        return Image(uiImage: uiImage)
    }

    private func loadPostAsset(from item: PhotosPickerItem) async {
        guard let data = try? await item.loadTransferable(type: Data.self) else {
            return
        }

        let asset = PickedImageAsset(
            data: data,
            contentType: item.supportedContentTypes.first
        )
        viewModel.applyPickedImageAsset(asset)
    }
}
