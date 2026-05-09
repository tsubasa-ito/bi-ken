import SwiftUI

struct OshiArtworkPickerView: View {
    @AppStorage("oshiArtworkData") private var oshiArtworkData: Data = Data()
    @State private var vm = CollectionViewModel()
    @Environment(\.dismiss) private var dismiss

    private var selectedArtworkID: String? {
        (try? JSONDecoder().decode(Artwork.self, from: oshiArtworkData))?.id
    }

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading {
                    ProgressView().tint(.appPrimary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if vm.artworks.isEmpty {
                    emptyView
                } else {
                    artworkGrid
                }
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("推し作品を選ぶ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                        .foregroundStyle(.appPrimary)
                }
            }
        }
        .task { await vm.load() }
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 48))
                .foregroundStyle(.appTextSecondary)
            Text("まだ推し作品がありません。\nクイズに挑戦して作品と出会いましょう！")
                .font(.subheadline)
                .foregroundStyle(.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var artworkGrid: some View {
        let columns = [GridItem(.flexible(), spacing: 2), GridItem(.flexible(), spacing: 2)]
        return ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(vm.artworks) { artwork in
                    artworkCell(artwork: artwork)
                }
            }
        }
    }

    private func artworkCell(artwork: Artwork) -> some View {
        let isSelected = selectedArtworkID == artwork.id
        return Button {
            selectArtwork(artwork)
        } label: {
            ZStack(alignment: .bottomLeading) {
                AsyncImage(url: artwork.imageURL) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.appCardBG
                }
                .frame(height: 180)
                .clipped()

                LinearGradient(
                    colors: [.clear, .black.opacity(0.7)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text(artwork.displayArtist)
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(artwork.displayTitle)
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.85))
                        .lineLimit(1)
                }
                .padding(10)

                if isSelected {
                    Color.appPrimary.opacity(0.35)
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        .padding(8)
                }
            }
            .frame(height: 180)
            .clipped()
        }
    }

    private func selectArtwork(_ artwork: Artwork) {
        if let data = try? JSONEncoder().encode(artwork) {
            oshiArtworkData = data
        }
        dismiss()
    }
}
