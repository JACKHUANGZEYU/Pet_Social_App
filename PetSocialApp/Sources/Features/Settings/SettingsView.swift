import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var container: AppContainer
    @ObservedObject private var session: AppSessionStore
    @State private var isConfirmingSignOut = false
    @State private var isSigningOut = false

    init(session: AppSessionStore) {
        _session = ObservedObject(wrappedValue: session)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                accountSummary
                petSummary
                backendSummary
                aiSummary
                signOutButton
            }
            .padding(20)
        }
        .background(container.theme.palette.appBackground.ignoresSafeArea())
        .navigationTitle("Settings")
        .confirmationDialog(
            "Sign out of PetSocial?",
            isPresented: $isConfirmingSignOut,
            titleVisibility: .visible
        ) {
            Button("Sign Out", role: .destructive) {
                signOut()
            }

            Button("Cancel", role: .cancel) { }
        } message: {
            Text("You can sign back in anytime.")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Account")
                .font(.largeTitle.weight(.bold))

            Text("Review who's signed in, which pet is active, and what backend this build is using.")
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    private var accountSummary: some View {
        SettingsCard(title: "Current User", systemImage: "person.crop.circle.fill") {
            if let user = session.currentUser {
                VStack(alignment: .leading, spacing: 12) {
                    SettingsInfoRow(label: "Name", value: user.displayName)
                    SettingsInfoRow(label: "Email", value: user.email)
                    SettingsInfoRow(label: "User ID", value: user.id)
                }
            } else {
                Text("No signed-in user is available.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var petSummary: some View {
        SettingsCard(title: "Current Pet", systemImage: "pawprint.circle.fill") {
            if let pet = session.currentPetProfile {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 14) {
                        PetAvatarView(imageURL: pet.avatarURL, size: 64)

                        VStack(alignment: .leading, spacing: 6) {
                            Text(pet.name)
                                .font(.headline)

                            Text(pet.handle)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Text("\(pet.petType.rawValue.capitalized) - \(pet.breed) - \(pet.age)y")
                                .font(.footnote.weight(.medium))
                                .foregroundStyle(.secondary)
                        }
                    }

                    if !pet.bio.isEmpty {
                        Text(pet.bio)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    if !pet.personalityTags.isEmpty {
                        PersonalityTagRow(tags: pet.personalityTags)
                    }
                }
            } else {
                Text("No active pet profile is available.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var backendSummary: some View {
        SettingsCard(title: "Backend Mode", systemImage: "server.rack") {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(container.environment.backendMode.displayName)
                        .font(.headline)

                    Spacer()

                    Text(container.environment.backendMode.badgeText)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(container.theme.palette.accent)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule(style: .continuous)
                                .fill(container.theme.palette.accentSoft)
                        )
                }

                Text(container.environment.backendMode.description)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var aiSummary: some View {
        SettingsCard(title: "AI Mode", systemImage: "sparkles") {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(container.environment.ai.mode.displayName)
                        .font(.headline)

                    Spacer()

                    Text(container.environment.ai.mode.badgeText)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(container.theme.palette.accent)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule(style: .continuous)
                                .fill(container.theme.palette.accentSoft)
                        )
                }

                Text(container.environment.ai.mode.description)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var signOutButton: some View {
        Button {
            isConfirmingSignOut = true
        } label: {
            HStack {
                if isSigningOut {
                    ProgressView()
                        .tint(.white)
                }

                Text(isSigningOut ? "Signing Out..." : "Sign Out")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.white)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(red: 0.71, green: 0.22, blue: 0.18))
        )
        .disabled(isSigningOut)
    }

    private func signOut() {
        guard !isSigningOut else { return }

        isSigningOut = true
        Task { @MainActor in
            await session.signOut()
            isSigningOut = false
        }
    }
}

private struct SettingsCard<Content: View>: View {
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
        VStack(alignment: .leading, spacing: 16) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .foregroundStyle(Color(red: 0.16, green: 0.12, blue: 0.10))

            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.92))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color(red: 0.90, green: 0.82, blue: 0.74).opacity(0.75))
        )
    }
}

private struct SettingsInfoRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(value)
                .font(.subheadline.weight(.medium))
                .textSelection(.enabled)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private extension BackendMode {
    var displayName: String {
        switch self {
        case .mock:
            return "Mock data"
        case .supabase:
            return "Supabase"
        }
    }

    var badgeText: String {
        rawValue.uppercased()
    }

    var description: String {
        switch self {
        case .mock:
            return "This build is using local seed data for fast previews and development."
        case .supabase:
            return "This build is connected to the configured Supabase project."
        }
    }
}

private extension AIMode {
    var displayName: String {
        switch self {
        case .mock:
            return "Mock AI"
        case .proxy:
            return "AI Proxy"
        }
    }

    var badgeText: String {
        rawValue.uppercased()
    }

    var description: String {
        switch self {
        case .mock:
            return "AI helpers use local generated suggestions so you can test the product flow without an API key."
        case .proxy:
            return "AI helpers call your configured proxy backend. Keep provider secret keys on that server, not inside the iOS app."
        }
    }
}
