import SwiftUI

struct PostCardView: View {
    let post: Post
    let author: PetProfile?
    var canDelete = false
    var isDeleting = false
    var onDelete: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                PetAvatarView(imageURL: author?.avatarURL, size: 44)

                VStack(alignment: .leading, spacing: 4) {
                    Text(author?.name ?? "Unknown Pet")
                        .font(.headline)

                    Text(author?.handle ?? "@mystery_pet")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                HStack(spacing: 8) {
                    Text(post.createdAt.feedTimestamp)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if canDelete {
                        Menu {
                            Button(role: .destructive) {
                                onDelete?()
                            } label: {
                                Label("Delete Post", systemImage: "trash")
                            }
                            .disabled(isDeleting)
                        } label: {
                            if isDeleting {
                                ProgressView()
                                    .controlSize(.small)
                            } else {
                                Image(systemName: "ellipsis.circle")
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }

            if let text = post.text, !text.isEmpty {
                Text(text)
                    .font(.body)
                    .foregroundStyle(Color(red: 0.16, green: 0.12, blue: 0.10))
            }

            if let imageURL = post.imageURL {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color(red: 0.94, green: 0.91, blue: 0.88))
                        .overlay {
                            ProgressView()
                        }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.white.opacity(0.94))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(Color(red: 0.92, green: 0.86, blue: 0.80), lineWidth: 1)
        )
    }
}
