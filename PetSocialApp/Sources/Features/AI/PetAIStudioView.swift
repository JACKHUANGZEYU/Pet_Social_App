import SwiftUI

struct PetAIStudioView: View {
    @EnvironmentObject private var container: AppContainer
    @StateObject private var viewModel: PetAIStudioViewModel

    init(viewModel: PetAIStudioViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                hero
                controls
                status
                results
            }
            .padding(20)
        }
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.95, blue: 0.90),
                    Color(red: 0.88, green: 0.96, blue: 0.93)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .navigationTitle("AI Studio")
        .task {
            if viewModel.studioPack == nil {
                viewModel.generateStudioPack()
            }
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Pet AI Studio")
                .font(.caption.weight(.bold))
                .tracking(1.2)
                .foregroundStyle(.secondary)

            Text("Turn your pet into a tiny social character.")
                .font(.system(size: 30, weight: .bold, design: .rounded))

            if let pet = viewModel.currentPet {
                HStack(spacing: 12) {
                    PetAvatarView(imageURL: pet.avatarURL, size: 56)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(pet.name)
                            .font(.headline)

                        Text("\(pet.handle) AI voice lab")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Creative Direction")
                .font(.headline)

            TextField(
                "Try: park day, new toy, sleepy Sunday...",
                text: $viewModel.focus,
                axis: .vertical
            )
            .lineLimit(3, reservesSpace: true)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.92))
            )

            Picker("Voice Style", selection: $viewModel.selectedStyle) {
                ForEach(PetAIWritingStyle.allCases) { style in
                    Text(style.displayName).tag(style)
                }
            }
            .pickerStyle(.segmented)

            Button {
                viewModel.generateStudioPack()
            } label: {
                HStack {
                    if viewModel.isGenerating {
                        ProgressView()
                            .tint(.white)
                    }

                    Label("Generate AI Pack", systemImage: "sparkles")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(red: 0.14, green: 0.33, blue: 0.27))
            )
            .disabled(viewModel.isGenerating)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.white.opacity(0.76))
        )
    }

    @ViewBuilder
    private var status: some View {
        if let statusMessage = viewModel.statusMessage {
            Text(statusMessage)
                .font(.footnote.weight(.medium))
                .foregroundStyle(Color(red: 0.17, green: 0.37, blue: 0.58))
        }
    }

    @ViewBuilder
    private var results: some View {
        if let pack = viewModel.studioPack {
            VStack(alignment: .leading, spacing: 16) {
                AIResultCard(title: "Voice Sample", systemImage: "quote.bubble") {
                    Text(pack.voiceSample)
                        .font(.body.weight(.medium))
                }

                AIResultCard(title: "Post Ideas", systemImage: "text.bubble") {
                    AIList(items: pack.postIdeas)
                }

                AIResultCard(title: "Pet-to-Pet Icebreakers", systemImage: "pawprint.circle") {
                    AIList(items: pack.icebreakers)
                }

                AIResultCard(title: "Creator Reminders", systemImage: "checklist") {
                    AIList(items: pack.careReminders)
                }
            }
        } else if !viewModel.isGenerating {
            EmptyStateCard(
                title: "Ready for sparks",
                message: "Generate an AI pack to get voice samples, post ideas, and pet-social prompts.",
                systemImage: "sparkles"
            )
        }
    }
}

private struct AIResultCard<Content: View>: View {
    let title: String
    let systemImage: String
    let content: Content

    init(
        title: String,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.systemImage = systemImage
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: systemImage)
                .font(.headline)

            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.93))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color(red: 0.88, green: 0.80, blue: 0.70), lineWidth: 1)
        )
    }
}

private struct AIList: View {
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "sparkle")
                        .font(.caption)
                        .foregroundStyle(Color(red: 0.90, green: 0.40, blue: 0.17))
                        .padding(.top, 3)

                    Text(item)
                        .font(.subheadline)
                }
            }
        }
    }
}
