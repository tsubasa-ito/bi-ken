import SwiftUI

struct CollectionView: View {
    @State private var vm = CollectionViewModel()
    @State private var selectedEra: Era?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    eraFilter

                    if vm.isLoading {
                        Spacer()
                        ProgressView().tint(.appPrimary)
                        Spacer()
                    } else if let errorMsg = vm.error {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "exclamationmark.circle").font(.title).foregroundStyle(.appError)
                            Text(errorMsg).foregroundStyle(.appTextSecondary).multilineTextAlignment(.center)
                            Button("再試行") { Task { await vm.load(era: selectedEra) } }
                                .buttonStyle(.borderedProminent).tint(.appPrimary)
                        }
                        Spacer()
                    } else if vm.artworks.isEmpty {
                        Spacer()
                        Text("作品が見つかりませんでした").foregroundStyle(.appTextSecondary)
                        Spacer()
                    } else {
                        artworkGrid
                    }
                }
            }
            .navigationTitle("コレクション")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationDestination(for: Artwork.self) { artwork in
                ArtworkDetailView(artwork: artwork)
            }
        }
        .task { await vm.load(era: selectedEra) }
        .onChange(of: selectedEra) { _, new in
            Task { await vm.load(era: new) }
        }
    }

    private var eraFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(title: "すべて", era: nil)
                ForEach(Era.allCases, id: \.self) { era in
                    filterChip(title: era.japaneseName, era: era)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    private func filterChip(title: String, era: Era?) -> some View {
        Button {
            selectedEra = era
        } label: {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(selectedEra == era ? .white : .appTextSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    selectedEra == era ? Color.appPrimary : Color.appSurfaceSecondary,
                    in: Capsule()
                )
        }
    }

    private var artworkGrid: some View {
        let columns = [GridItem(.flexible(), spacing: 2), GridItem(.flexible(), spacing: 2)]
        return ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(vm.artworks) { artwork in
                    NavigationLink(value: artwork) {
                        artworkCell(artwork: artwork)
                    }
                }
            }
        }
    }

    private func artworkCell(artwork: Artwork) -> some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: artwork.imageURL) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color.appSurfaceSecondary
            }
            .frame(height: 200)
            .clipped()

            LinearGradient(colors: [.clear, .black.opacity(0.7)], startPoint: .top, endPoint: .bottom)

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
    }
}
