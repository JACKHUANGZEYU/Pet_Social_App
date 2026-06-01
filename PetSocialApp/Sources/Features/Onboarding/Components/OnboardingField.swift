import SwiftUI

struct OnboardingField: View {
    let title: String
    let prompt: String
    @Binding var text: String
    var axis: Axis = .horizontal
    var textInputAutocapitalization: TextInputAutocapitalization = .words
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            TextField(prompt, text: $text, axis: axis)
                .textInputAutocapitalization(textInputAutocapitalization)
                .keyboardType(keyboardType)
                .autocorrectionDisabled()
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                )
        }
    }
}
