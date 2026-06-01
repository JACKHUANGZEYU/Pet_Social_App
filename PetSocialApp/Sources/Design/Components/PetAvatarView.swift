import SwiftUI

struct PetAvatarView: View {
    let imageURL: URL?
    let size: CGFloat

    var body: some View {
        AsyncImage(url: imageURL) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            ZStack {
                Circle()
                    .fill(Color(red: 0.95, green: 0.90, blue: 0.84))

                Image(systemName: "pawprint.fill")
                    .font(.system(size: size * 0.34, weight: .semibold))
                    .foregroundStyle(Color(red: 0.56, green: 0.45, blue: 0.36))
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(Color.white.opacity(0.8), lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
    }
}
