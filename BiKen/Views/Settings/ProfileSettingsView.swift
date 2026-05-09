import SwiftUI

struct ProfileSettingsView: View {
    private let progress = UserProgress.shared
    @State private var draftName: String = ""
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool
    @AppStorage("oshiArtworkData") private var oshiArtworkData: Data = Data()
    @State private var showOshiPicker = false

    private var oshiArtwork: Artwork? {
        guard !oshiArtworkData.isEmpty else { return nil }
        return try? JSONDecoder().decode(Artwork.self, from: oshiArtworkData)
    }

    var body: some View {
        List {
            Section {
                oshiArtworkHeader
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())

            Section("表示名") {
                TextField("例：田中 花子", text: $draftName)
                    .focused($isFocused)
                    .foregroundStyle(.appText)
                    .submitLabel(.done)
                    .onSubmit { save() }
            }
            .listRowBackground(Color.appCardBG)

            Section {
                Text("表示名はホーム画面のアイコンに反映されます。")
                    .font(.footnote)
                    .foregroundStyle(.appTextSecondary)
            }
            .listRowBackground(Color.clear)
        }
        .scrollContentBackground(.hidden)
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("プロフィール")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("保存") { save() }
                    .foregroundStyle(.appPrimary)
                    .fontWeight(.semibold)
                    .disabled(draftName.trimmingCharacters(in: .whitespaces) == progress.userName)
            }
        }
        .onAppear {
            draftName = progress.userName
        }
        .sheet(isPresented: $showOshiPicker) {
            OshiArtworkPickerView()
        }
    }

    private var oshiArtworkHeader: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                if let artwork = oshiArtwork {
                    AsyncImage(url: artwork.imageURL) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color.appCardBG
                            .overlay(ProgressView().tint(.appPrimary))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .clipped()

                    LinearGradient(
                        colors: [.clear, .black.opacity(0.8)],
                        startPoint: .top,
                        endPoint: .bottom
                    )

                    VStack(alignment: .leading, spacing: 4) {
                        Text(artwork.displayArtist)
                            .font(.subheadline.bold())
                            .foregroundStyle(.white)
                        Text(artwork.displayTitle)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.85))
                    }
                    .padding(16)
                } else {
                    Color.appCardBG
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .overlay(
                            VStack(spacing: 12) {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.system(size: 40))
                                    .foregroundStyle(.appTextSecondary)
                                Text("推し作品を選んでプロフィールに飾ろう")
                                    .font(.subheadline)
                                    .foregroundStyle(.appTextSecondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 24)
                            }
                        )
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 16)
            .padding(.top, 16)

            HStack {
                Text(progress.levelTitle)
                    .font(.system(size: 13))
                    .foregroundStyle(.appTextSecondary)

                Spacer()

                Button {
                    showOshiPicker = true
                } label: {
                    Label("変更", systemImage: "photo.badge.plus")
                        .font(.subheadline)
                        .foregroundStyle(.appPrimary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    private func save() {
        let trimmed = draftName.trimmingCharacters(in: .whitespaces)
        progress.updateUserName(trimmed)
        isFocused = false
        dismiss()
    }
}
