import PhotosUI
import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct OnboardingFlowView: View {
    @StateObject private var viewModel: PetOnboardingViewModel
    @State private var selectedAvatarItem: PhotosPickerItem?

    init(viewModel: PetOnboardingViewModel = PetOnboardingViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                hero
                progressSection
                stepCard
                actions
            }
            .padding(24)
        }
        .background(
            LinearGradient(
                colors: [
                    Color(red: 1.00, green: 0.96, blue: 0.90),
                    Color(red: 0.89, green: 0.95, blue: 1.00)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .navigationTitle("Create Pet Profile")
        .navigationBarTitleDisplayMode(.inline)
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

    private var hero: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Onboarding")
                .font(.caption.weight(.bold))
                .tracking(1.2)
                .foregroundStyle(.secondary)

            Text(viewModel.currentStep.title)
                .font(.system(size: 32, weight: .bold, design: .rounded))

            Text(viewModel.currentStep.subtitle)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ProgressView(value: viewModel.progressValue)
                .tint(Color(red: 0.19, green: 0.39, blue: 0.60))

            HStack {
                ForEach(PetOnboardingStep.allCases) { step in
                    Text(step.title)
                        .font(.caption.weight(step == viewModel.currentStep ? .bold : .regular))
                        .foregroundStyle(step == viewModel.currentStep ? .primary : .secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    private var stepCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            if let errorMessage = viewModel.errorMessage {
                statusPill(text: errorMessage, tint: .red)
            }

            if let successMessage = viewModel.successMessage {
                statusPill(text: successMessage, tint: .green)
            }

            avatarPreview

            switch viewModel.currentStep {
            case .identity:
                identityFields
            case .details:
                detailFields
            case .personality:
                personalityFields
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(.systemBackground).opacity(0.84))
        )
    }

    private var avatarPreview: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(red: 0.89, green: 0.92, blue: 0.96))
                .frame(width: 88, height: 88)
                .overlay {
                    if let image = avatarPreviewImage {
                        image
                            .resizable()
                            .scaledToFill()
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    } else if let url = URL(string: viewModel.draft.avatarURL), !viewModel.draft.avatarURL.isEmpty {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Image(systemName: "pawprint.circle.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(.secondary)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    } else {
                        Image(systemName: "pawprint.circle.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(.secondary)
                    }
                }

            VStack(alignment: .leading, spacing: 6) {
                Text(viewModel.draft.petName.isEmpty ? "Your pet" : viewModel.draft.petName)
                    .font(.headline)

                Text(viewModel.draft.petHandle.isEmpty ? "@petid" : "@\(viewModel.draft.petHandle)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("For phase 3, a remote avatar URL can be imported into app storage when the live backend is enabled.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var identityFields: some View {
        VStack(alignment: .leading, spacing: 18) {
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

            OnboardingField(
                title: "Avatar URL",
                prompt: "https://...",
                text: $viewModel.draft.avatarURL,
                textInputAutocapitalization: .never,
                keyboardType: .URL
            )

            PhotosPicker(selection: $selectedAvatarItem, matching: .images) {
                Label("Choose From Photos", systemImage: "photo.on.rectangle")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color(red: 0.93, green: 0.95, blue: 0.99))
                    )
            }
            .buttonStyle(.plain)

            if viewModel.draft.avatarAsset != nil {
                Button("Use URL Instead") {
                    selectedAvatarItem = nil
                    viewModel.applyAvatarAsset(nil)
                }
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color(red: 0.17, green: 0.37, blue: 0.58))
            }
        }
    }

    private var detailFields: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Pet Type")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)

                Picker("Pet Type", selection: $viewModel.draft.petType) {
                    ForEach(PetType.allCases) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                .pickerStyle(.menu)
            }

            OnboardingField(title: "Breed", prompt: "Pembroke Welsh Corgi", text: $viewModel.draft.breed)
            OnboardingField(
                title: "Age",
                prompt: "2",
                text: $viewModel.draft.age,
                textInputAutocapitalization: .never,
                keyboardType: .numberPad
            )

            VStack(alignment: .leading, spacing: 8) {
                Text("Gender")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)

                Picker("Gender", selection: $viewModel.draft.gender) {
                    ForEach(PetGender.allCases) { gender in
                        Text(gender.displayName).tag(gender)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }

    private var personalityFields: some View {
        VStack(alignment: .leading, spacing: 18) {
            Button {
                viewModel.generateAIProfile()
            } label: {
                HStack {
                    if viewModel.isGeneratingAI {
                        ProgressView()
                    }

                    Label("AI Draft Bio & Tags", systemImage: "sparkles")
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

            OnboardingField(
                title: "Short Bio",
                prompt: "Tiny legs. Big opinions. Loves park gossip.",
                text: $viewModel.draft.bio,
                axis: .vertical
            )

            VStack(alignment: .leading, spacing: 10) {
                Text("Personality Tags")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    TextField("playful", text: $viewModel.draft.pendingTag)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color(.secondarySystemBackground))
                        )

                    Button("Add") {
                        viewModel.addPendingTag()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(red: 0.33, green: 0.48, blue: 0.24))
                }

                if !viewModel.draft.personalityTags.isEmpty {
                    FlexibleTagWrap(tags: viewModel.draft.personalityTags, onRemove: viewModel.removeTag(_:))
                } else {
                    Text("Try tags like sleepy, dramatic, snack-driven, curious.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var actions: some View {
        HStack(spacing: 12) {
            if viewModel.currentStep != .identity {
                Button("Back") {
                    viewModel.goBack()
                }
                .buttonStyle(.bordered)
            }

            Button(action: viewModel.continueOrSubmit) {
                HStack {
                    if viewModel.isSaving {
                        ProgressView()
                            .tint(.white)
                    }

                    Text(viewModel.isOnLastStep ? "Create Pet Profile" : "Continue")
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
    }

    private func statusPill(text: String, tint: Color) -> some View {
        Text(text)
            .font(.footnote.weight(.medium))
            .foregroundStyle(tint)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                Capsule(style: .continuous)
                    .fill(tint.opacity(0.12))
            )
    }

    private var avatarPreviewImage: Image? {
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

        let asset = PickedImageAsset(
            data: data,
            contentType: item.supportedContentTypes.first
        )
        viewModel.applyAvatarAsset(asset)
    }
}

private struct FlexibleTagWrap: View {
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

#Preview {
    NavigationStack {
        OnboardingFlowView()
    }
}
