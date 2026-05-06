import SwiftUI

struct ArtworkDetailView: View {
    let artwork: Artwork
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    artworkImage
                    infoSection
                    descriptionSection
                }
            }
        }
        .navigationBarHidden(true)
        .overlay(alignment: .topLeading) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                    .padding(12)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .padding(16)
            .padding(.top, 40)
        }
    }

    private var artworkImage: some View {
        AsyncImage(url: artwork.imageURL) { image in
            image.resizable().scaledToFit()
        } placeholder: {
            Color.appSurfaceSecondary
                .frame(height: 300)
                .overlay { ProgressView().tint(.appPrimary) }
        }
        .frame(maxWidth: .infinity)
        .background(Color.appSurfaceSecondary)
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(artwork.displayTitle)
                .font(.title2.bold())
                .foregroundStyle(.white)

            HStack {
                Text(artwork.displayArtist)
                    .font(.headline)
                    .foregroundStyle(.appPrimary)
                Spacer()
                if let year = artwork.year {
                    Text("\(year)年")
                        .font(.subheadline)
                        .foregroundStyle(.appTextSecondary)
                }
            }

            HStack(spacing: 8) {
                tagView(text: artwork.era.japaneseName, color: .appPrimary)
                tagView(text: artwork.difficulty.rawValue, color: difficultyColor)
                if !artwork.medium.isEmpty {
                    tagView(text: japaneseMedium(artwork.medium), color: .appSurfaceSecondary)
                }
            }
        }
        .padding(20)
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("解説")
                .font(.headline.bold())
                .foregroundStyle(.white)

            Text(artwork.description)
                .font(.body)
                .foregroundStyle(.appTextSecondary)
                .lineSpacing(6)

            if let bio = artwork.artistBio, !bio.isEmpty {
                Divider().overlay(Color.appBorder)
                Text("作家について")
                    .font(.headline.bold())
                    .foregroundStyle(.white)
                Text(bio)
                    .font(.body)
                    .foregroundStyle(.appTextSecondary)
                    .lineSpacing(6)
            }
        }
        .padding(20)
    }

    private func tagView(text: String, color: Color) -> some View {
        Text(text)
            .font(.caption.bold())
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.15), in: Capsule())
    }

    private var difficultyColor: Color {
        switch artwork.difficulty {
        case .easy:   .appSuccess
        case .medium: .orange
        case .hard:   .appError
        }
    }

    private func japaneseMedium(_ medium: String) -> String {
        let lower = medium.lowercased()
        if lower.contains("oil on canvas") { return "油彩・カンヴァス" }
        if lower.contains("oil on panel") { return "油彩・板" }
        if lower.contains("tempera") { return "テンペラ" }
        if lower.contains("woodblock") || lower.contains("woodcut") { return "木版画" }
        if lower.contains("watercolor") { return "水彩" }
        if lower.contains("fresco") { return "フレスコ" }
        if lower.contains("ink") { return "墨画" }
        return medium
    }
}
