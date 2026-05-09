import SwiftUI

struct ProfileSettingsView: View {
    private let progress = UserProgress.shared
    @State private var draftName: String = ""
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool
    @AppStorage("oshiArtworkData") private var oshiArtworkData: Data = Data()
    @State private var showOshiPicker = false
    @State private var oshiArtwork: Artwork?

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
        .onChange(of: oshiArtworkData, initial: true) { _, data in
            guard !data.isEmpty else { oshiArtwork = nil; return }
            oshiArtwork = try? JSONDecoder().decode(Artwork.self, from: data)
        }
        .sheet(isPresented: $showOshiPicker) {
            OshiArtworkPickerView()
        }
    }

    private var oshiArtworkHeader: some View {
        VStack(alignment: .center, spacing: 0) {
            ZStack {
                if let artwork = oshiArtwork {
                    AsyncImage(url: artwork.imageURL) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        case .failure:
                            Color.appCardBG
                                .overlay(Image(systemName: "photo").foregroundStyle(.appTextSecondary))
                        case .empty:
                            Color.appCardBG
                                .overlay(ProgressView().tint(.appPrimary))
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(width: 96, height: 96)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.appBorder, lineWidth: 1.5))
                } else {
                    Circle()
                        .fill(Color.appCardBG)
                        .frame(width: 96, height: 96)
                        .overlay(Circle().stroke(Color.appBorder, lineWidth: 1.5))
                        .overlay(
                            Image(systemName: "photo.badge.plus")
                                .font(.system(size: 28))
                                .foregroundStyle(.appTextSecondary)
                        )
                }
            }
            .padding(.top, 24)

            if let artwork = oshiArtwork {
                VStack(spacing: 2) {
                    Text(artwork.displayArtist)
                        .font(.subheadline.bold())
                        .foregroundStyle(.appText)
                    Text(artwork.displayTitle)
                        .font(.caption)
                        .foregroundStyle(.appTextSecondary)
                }
                .padding(.top, 8)
            }

            Button {
                showOshiPicker = true
            } label: {
                Label("変更", systemImage: "photo.badge.plus")
                    .font(.subheadline)
                    .foregroundStyle(.appPrimary)
            }
            .padding(.top, 10)

            Text(progress.levelTitle)
                .font(.system(size: 13))
                .foregroundStyle(.appTextSecondary)
                .padding(.top, 4)
                .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
    }

    private func save() {
        let trimmed = draftName.trimmingCharacters(in: .whitespaces)
        progress.updateUserName(trimmed)
        isFocused = false
        dismiss()
    }
}
