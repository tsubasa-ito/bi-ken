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
                    .foregroundStyle(.appText)
                    .padding(12)
                    .background(Color.appCardBG, in: Circle())
                    .overlay(Circle().stroke(Color.appBorder, lineWidth: 1))
            }
            .padding(16)
            .padding(.top, 40)
        }
    }

    private var artworkImage: some View {
        AsyncImage(url: artwork.imageURL) { image in
            image.resizable().scaledToFit()
        } placeholder: {
            Color.appCardBG
                .frame(height: 300)
                .overlay { ProgressView().tint(.appPrimary) }
        }
        .frame(maxWidth: .infinity)
        .background(Color.appCardBG)
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(artwork.displayTitle)
                .font(.title2.bold())
                .foregroundStyle(.appText)

            HStack {
                Text(artwork.displayArtist)
                    .font(.headline)
                    .foregroundStyle(.appPrimary)
                Spacer()
                if let year = artwork.year {
                    Text("\(year)年頃")
                        .font(.subheadline)
                        .foregroundStyle(.appTextSecondary)
                }
            }

            HStack(spacing: 8) {
                tagView(text: artwork.era.japaneseName, color: .appPrimary)
                let medJa = artwork.shortMediumJa
                if !medJa.isEmpty {
                    tagView(text: medJa, color: .appTextSecondary)
                }
            }
        }
        .padding(20)
        .background(Color.appBackground)
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Divider().overlay(Color.appBorder)

            Text("解説")
                .font(.headline.bold())
                .foregroundStyle(.appText)

            Text(artwork.description)
                .font(.body)
                .foregroundStyle(.appTextSecondary)
                .lineSpacing(6)

            if let bio = artwork.artistBio, !bio.isEmpty {
                Divider().overlay(Color.appBorder)
                Text("作家について")
                    .font(.headline.bold())
                    .foregroundStyle(.appText)
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
            .background(color.opacity(0.12), in: Capsule())
    }

}
