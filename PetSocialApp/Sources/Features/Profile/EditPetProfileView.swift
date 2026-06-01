import PhotosUI
import SwiftUI
import UIKit

struct EditPetProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: EditPetProfileViewModel
    @State private var selectedAvatarItem: PhotosPickerItem?

    init(viewModel: EditPetProfileViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                avatarSection
                identitySection
                detailsSection
                personalitySection

                if let statusMessage = viewModel.statusMessage {
                    Text(statusMessage)
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(Color(red: 0.17, green: 0.37, blue: 0.58))
                }

                Button(action: viewModel.save) {
                    HStack {
                        if viewModel.isSaving {
                            ProgressView()
                                .tint(.white)
                        }

                        Text("Save Profile")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color(red: 0.17, green: 0.37, blue: 0.58))
                )
                .disabled(viewModel.isSaving)
            }
            .padding(24)
        }
        .navigationTitle("Edit Pet")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") {
                    dismiss()
                }
            }
        }
        .onChange(of: selectedAvatarItem) { _, newItem in
            guard let newItem else { return }
            Task {
                await loadAvatarAsset(from: newItem)
            }
        }
        .onChange(of: viewModel.draft.avatarURL) { _, _ in
            viewModel.remoteAvatarURLDidChange()
        }
    }

    private var avatarSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Avatar")
                .font(.headline)

            HStack(spacing: 16) {
                avatarPreview

                VStack(alignment: .leading, spacing: 10) {
                    PhotosPicker(selection: $selectedAvatarItem, matching: .images) {
                        Label("Choose Photo", systemImage: "photo.on.rectangle")
                            .font(.subheadline.weight(.semibold))
                    }
                    .buttonStyle(.bordered)

                    TextField("https://...", text: $viewModel.draft.avatarURL)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color(.secondarySystemBackground))
                        )

                    if viewModel.draft.avatarAsset != nil {
                        Button("Use URL Instead") {
                            selectedAvatarItem = nil
                            viewModel.applyAvatarAsset(nil)
                        }
                        .font(.footnote.weight(.semibold))
                    }
                }
            }
        }
    }

    private var avatarPreview: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(Color(red: 0.89, green: 0.92, blue: 0.96))
            .frame(width: 96, height: 96)
            .overlay {
                if let image = pickedAvatarImage {
                    image
                        .resizable()
                        .scaledToFill()
                } else if let url = URL(string: viewModel.draft.avatarURL), !viewModel.draft.avatarURL.isEmpty {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Image(systemName: "pawprint.circle.fill")
                            .font(.system(size: 34))
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Image(systemName: "pawprint.circle.fill")
                        .font(.system(size: 34))
                        .foregroundStyle(.secondary)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var identitySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Identity")
                .font(.headline)

            OnboardingField(
                title: "Pet Name",
                prompt: "Mochi",
                text: $viewModel.draft.petName,
                textInputAutocapitalization: .words
            )

            OnboardingField(
                title: "Pet ID",
                prompt: "mochi_the_corgi",
                text: $viewModel.draft.petHandle,
                textInputAutocapitalization: .never
            )
        }
    }

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Basics")
                .font(.headline)

            Picker("Pet Type", selection: $viewModel.draft.petType) {
                ForEach(PetType.allCases) { type in
                    Text(type.displayName).tag(type)
                }
            }
            .pickerStyle(.menu)

            OnboardingField(title: "Breed", prompt: "Pembroke Welsh Corgi", text: $viewModel.draft.breed)
            OnboardingField(
                title: "Age",
                prompt: "2",
                text: $viewModel.draft.age,
                textInputAutocapitalization: .never,
                keyboardType: .numberPad
            )

            Picker("Gender", selection: $viewModel.draft.gender) {
                ForEach(PetGender.allCases) { gender in
                    Text(gender.displayName).tag(gender)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var personalitySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Voice")
                .font(.headline)

            Button {
                viewModel.polishWithAI()
            } label: {
                HStack {
                    if viewModel.isGeneratingAI {
                        ProgressView()
                    }

                    Label("AI Polish Voice", systemImage: "sparkles")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
            }
            .buttonStyle(.plain)
            .foregroundStyle(Color(red: 0.14, green: 0.33, blue: 0.27))
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(red: 0.89, green: 0.97, blue: 0.91))
            )
            .disabled(viewModel.isGeneratingAI)

            OnboardingField(
                title: "Short Bio",
                prompt: "Tiny legs. Big opinions.",
                text: $viewModel.draft.bio,
                axis: .vertical
            )

            HStack(spacing: 10) {
                TextField("playful", text: $viewModel.draft.pendingTag)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color(.secondarySystemBackground))
                    )

                Button("Add") {
                    viewModel.addPendingTag()
                }
                .buttonStyle(.borderedProminent)
            }

            FlowTagList(tags: viewModel.draft.personalityTags) { tag in
                viewModel.removeTag(tag)
            }
        }
    }

    private var pickedAvatarImage: Image? {
        guard let data = viewModel.draft.avatarAsset?.data,
              let uiImage = UIImage(data: data) else {
            return nil
        }

        return Image(uiImage: uiImage)
    }

    private func loadAvatarAsset(from item: PhotosPickerItem) async {
        guard let data = try? await item.loadTransferable(type: Data.self) else {
            return
        }

        viewModel.applyAvatarAsset(
            PickedImageAsset(data: data, contentType: item.supportedContentTypes.first)
        )
    }
}

private struct FlowTagList: View {
    let tags: [String]
    let onRemove: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(tagRows(), id: \.self) { row in
                HStack {
                    ForEach(row, id: \.self) { tag in
                        TagChip(tag: tag) {
                            onRemove(tag)
                        }
                    }
                    Spacer(minLength: 0)
                }
            }
        }
    }

    private func tagRows(maxRowCharacterCount: Int = 22) -> [[String]] {
        var rows: [[String]] = [[]]
        var currentCount = 0

        for tag in tags {
            let projectedCount = currentCount + tag.count
            if projectedCount > maxRowCharacterCount, !rows[rows.count - 1].isEmpty {
                rows.append([tag])
                currentCount = tag.count
            } else {
                rows[rows.count - 1].append(tag)
                currentCount = projectedCount
            }
        }

        return rows
    }
}
