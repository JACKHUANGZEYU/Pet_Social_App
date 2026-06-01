import SwiftUI

struct AuthFlowView: View {
    @StateObject private var viewModel: AuthViewModel

    init(viewModel: AuthViewModel = AuthViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                modePicker
                formCard
                footer
            }
            .padding(24)
        }
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.97, green: 0.93, blue: 0.86),
                    Color(red: 0.92, green: 0.97, blue: 0.95)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .navigationTitle("Pet Social")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Pet identities first")
                .font(.caption.weight(.bold))
                .tracking(1.2)
                .foregroundStyle(.secondary)

            Text(viewModel.form.mode.title)
                .font(.system(size: 32, weight: .bold, design: .rounded))

            Text(viewModel.form.mode.subtitle)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    private var modePicker: some View {
        Picker("Auth Mode", selection: Binding(
            get: { viewModel.form.mode },
            set: { viewModel.updateMode($0) }
        )) {
            ForEach(AuthMode.allCases) { mode in
                Text(mode.rawValue).tag(mode)
            }
        }
        .pickerStyle(.segmented)
    }

    private var formCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            if let errorMessage = viewModel.errorMessage {
                statusPill(text: errorMessage, tint: .red)
            }

            if let successMessage = viewModel.successMessage {
                statusPill(text: successMessage, tint: .green)
            }

            if viewModel.form.mode == .signUp {
                AuthField(
                    title: "Owner Display Name",
                    prompt: "How should we greet you?",
                    text: $viewModel.form.ownerDisplayName,
                    textContentType: .name,
                    textInputAutocapitalization: .words
                )
            }

            AuthField(
                title: "Email",
                prompt: "name@example.com",
                text: $viewModel.form.email,
                keyboardType: .emailAddress,
                textContentType: .emailAddress
            )

            AuthField(
                title: "Password",
                prompt: "At least 6 characters",
                text: $viewModel.form.password,
                textContentType: .password,
                isSecure: true
            )

            if viewModel.form.mode == .signUp {
                AuthField(
                    title: "Confirm Password",
                    prompt: "Re-enter password",
                    text: $viewModel.form.confirmPassword,
                    textContentType: .password,
                    isSecure: true
                )
            }

            Button(action: viewModel.submit) {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    }

                    Text(viewModel.form.mode.primaryActionTitle)
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
            .disabled(viewModel.isLoading)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(.systemBackground).opacity(0.84))
        )
    }

    private var footer: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("MVP feature notes")
                .font(.headline)

            Text("This screen is wired through the shared session store, so the same flow works with local mock data or a configured Supabase backend.")
                .font(.footnote)
                .foregroundStyle(.secondary)
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
}

struct AuthScreen: View {
    private let viewModel: AuthViewModel

    init(viewModel: AuthViewModel = AuthViewModel()) {
        self.viewModel = viewModel
    }

    var body: some View {
        AuthFlowView(viewModel: viewModel)
    }
}

#Preview {
    NavigationStack {
        AuthFlowView()
    }
}
