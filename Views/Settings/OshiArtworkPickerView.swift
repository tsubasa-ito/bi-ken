import SwiftUI

struct OshiArtworkPickerView: View {
    @AppStorage("oshiArtworkData") private var oshiArtworkData: Data = Data()
    @State private var vm = CollectionViewModel()
    @State private var selectedArtworkID: String?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading {
                    ProgressView().tint(.appPrimary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMsg = vm.error {
                    errorView(errorMsg)
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
            .task { await vm.load() }
            .onChange(of: oshiArtworkData, initial: true) { _, data in
                selectedArtworkID = (try? JSONDecoder().decode(Artwork.self, from: data))?.id
            }
        }
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

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.circle")
                .font(.title)
                .foregroundStyle(.appIncorrect)
            Text(message)
                .foregroundStyle(.appTextSecondary)
                .multilineTextAlignment(.center)
            Button("再試行") { Task { await vm.load() } }
                .buttonStyle(.borderedProminent)
                .tint(.appPrimary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
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
                CachedAsyncImage(url: artwork.imageURL) { image in
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
        guard let data = try? JSONEncoder().encode(artwork) else { return }
        oshiArtworkData = data
        dismiss()
    }
}
