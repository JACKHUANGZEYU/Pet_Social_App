import SwiftUI

struct PersonalityTagRow: View {
    let tags: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    Text("#\(tag)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color(red: 0.53, green: 0.28, blue: 0.11))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule(style: .continuous)
                                .fill(Color(red: 0.98, green: 0.90, blue: 0.82))
                        )
                }
            }
        }
    }
}
