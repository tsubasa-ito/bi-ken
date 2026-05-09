import SwiftUI

struct CollectionView: View {
    @State private var vm = CollectionViewModel()
    @State private var selectedEra: Era?
    @State private var showBookmarksOnly = false
    @State private var displayedArtworks: [Artwork] = []

    private func refreshDisplayedArtworks() {
        guard showBookmarksOnly else {
            displayedArtworks = vm.artworks
            return
        }
        let ids = Set(UserProgress.shared.bookmarkedArtworkIDs)
        displayedArtworks = vm.artworks.filter { ids.contains($0.id) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                customHeader

                Rectangle()
                    .fill(Color.appBorder)
                    .frame(height: 1.5)

                if vm.isLoading {
                    Spacer()
                    ProgressView().tint(.appPrimary)
                    Spacer()
                } else if let errorMsg = vm.error {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.circle").font(.title).foregroundStyle(.appIncorrect)
                        Text(errorMsg).foregroundStyle(.appTextSecondary).multilineTextAlignment(.center)
                        Button("再試行") { Task { await vm.load(era: selectedEra) } }
                            .buttonStyle(.borderedProminent).tint(.appPrimary)
                    }
                    Spacer()
                } else if displayedArtworks.isEmpty {
                    Spacer()
                    Text(showBookmarksOnly ? "ブックマークした作品がありません" : "作品が見つかりませんでした")
                        .foregroundStyle(.appTextSecondary)
                    Spacer()
                } else {
                    eraFilter
                    artworkGrid
                }
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationBarHidden(true)
            .navigationDestination(for: Artwork.self) { artwork in
                ArtworkDetailView(artwork: artwork)
            }
        }
        .task { await vm.load(era: selectedEra) }
        .onChange(of: selectedEra) { _, new in
            Task { await vm.load(era: new) }
        }
        .onChange(of: vm.artworks, initial: true) { _, _ in refreshDisplayedArtworks() }
        .onChange(of: showBookmarksOnly) { _, _ in refreshDisplayedArtworks() }
        .onChange(of: UserProgress.shared.bookmarkedArtworkIDs) { _, _ in refreshDisplayedArtworks() }
    }

    private var customHeader: some View {
        ZStack {
            Color.appBackground
            Text("コレクション")
                .font(.system(size: 18, weight: .semibold, design: .serif))
                .foregroundStyle(.appText)
        }
        .frame(height: 104)
    }

    private var eraFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                bookmarkChip
                filterChip(title: "すべて", era: nil)
                ForEach(Era.allCases, id: \.self) { era in
                    filterChip(title: era.japaneseName, era: era)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    private var bookmarkChip: some View {
        Button {
            showBookmarksOnly.toggle()
            if showBookmarksOnly { selectedEra = nil }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: showBookmarksOnly ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 11))
                Text("ブックマーク")
                    .font(.caption.weight(.medium))
            }
            .foregroundStyle(showBookmarksOnly ? .white : .appTextSecondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(showBookmarksOnly ? Color.appPrimary : Color.appCardBG, in: Capsule())
        }
    }

    private func filterChip(title: String, era: Era?) -> some View {
        let isSelected = !showBookmarksOnly && selectedEra == era
        return Button {
            selectedEra = era
            showBookmarksOnly = false
        } label: {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(isSelected ? .white : .appTextSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? Color.appPrimary : Color.appCardBG, in: Capsule())
        }
    }

    private var artworkGrid: some View {
        let columns = [GridItem(.flexible(), spacing: 2), GridItem(.flexible(), spacing: 2)]
        return ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(displayedArtworks) { artwork in
                    NavigationLink(value: artwork) {
                        artworkCell(artwork: artwork)
                    }
                }
            }
        }
    }

    private func artworkCell(artwork: Artwork) -> some View {
        ZStack(alignment: .bottomLeading) {
            if let imageURL = artwork.imageURL {
                CachedAsyncImage(url: imageURL) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.appCardBG
                }
                .frame(height: 200)
                .clipped()
            } else {
                ZStack {
                    Color.appCardBG
                    VStack(spacing: 8) {
                        Image(systemName: "photo")
                            .font(.system(size: 30))
                            .foregroundStyle(.appTextTertiary)
                        Text(artwork.displayTitle)
                            .font(.system(size: 11, weight: .medium, design: .serif))
                            .foregroundStyle(.appTextSecondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .padding(.horizontal, 12)
                    }
                }
                .frame(height: 200)
            }

            LinearGradient(colors: [.clear, .black.opacity(0.65)], startPoint: .center, endPoint: .bottom)

            VStack(alignment: .leading, spacing: 2) {
                Text(artwork.displayArtist)
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(artwork.era.japaneseName)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(10)
        }
        .frame(height: 200)
        .clipped()
        .overlay(alignment: .topTrailing) {
            if UserProgress.shared.isBookmarked(artwork.id) {
                Image(systemName: "bookmark.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(.white)
                    .padding(6)
                    .background(Color.appPrimary, in: Circle())
                    .padding(8)
            }
        }
    }
}
