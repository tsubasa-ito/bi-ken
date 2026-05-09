import SwiftUI

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    @ViewBuilder let content: (Image) -> Content
    @ViewBuilder let placeholder: () -> Placeholder

    @State private var uiImage: UIImage?

    var body: some View {
        Group {
            if let uiImage {
                content(Image(uiImage: uiImage))
            } else {
                placeholder()
            }
        }
        .task(id: url) {
            // キャッシュヒット時はリセットせず即セット、ミス時はプレースホルダーを挟んでロード
            if let url, let cached = ImageCache.shared.image(for: url) {
                uiImage = cached
                return
            }
            uiImage = nil
            await load()
        }
    }

    private func load() async {
        guard let url else { return }
        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let image = UIImage(data: data) else { return }
        ImageCache.shared.store(image, for: url)
        uiImage = image
    }
}
