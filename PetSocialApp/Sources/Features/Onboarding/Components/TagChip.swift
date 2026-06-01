import SwiftUI

struct TagChip: View {
    let tag: String
    var onRemove: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 8) {
            Text("#\(tag)")
                .font(.footnote.weight(.semibold))

            if let onRemove {
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption)
                }
                .buttonStyle(.plain)
            }
        }
        .foregroundStyle(Color(red: 0.28, green: 0.20, blue: 0.13))
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(
            Capsule(style: .continuous)
                .fill(Color(red: 0.97, green: 0.88, blue: 0.73))
        )
    }
}
