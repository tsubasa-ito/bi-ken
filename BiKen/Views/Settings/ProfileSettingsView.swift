import SwiftUI

struct ProfileSettingsView: View {
    private let progress = UserProgress.shared
    @State private var draftName: String = ""
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool

    var body: some View {
        List {
            Section {
                avatarHeader
            }
            .listRowBackground(Color.clear)

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
    }

    private var avatarHeader: some View {
        HStack {
            Spacer()
            VStack(spacing: 12) {
                Circle()
                    .fill(Color.appCardBG)
                    .frame(width: 72, height: 72)
                    .overlay(Circle().stroke(Color.appBorder, lineWidth: 1.5))
                    .overlay(
                        Text(avatarInitial)
                            .font(.system(size: 28, weight: .medium))
                            .foregroundStyle(.appTextSecondary)
                    )
                Text(progress.levelTitle)
                    .font(.system(size: 13))
                    .foregroundStyle(.appTextSecondary)
            }
            .padding(.vertical, 16)
            Spacer()
        }
    }

    private var avatarInitial: String {
        let name = draftName.trimmingCharacters(in: .whitespaces)
        guard let first = name.first else { return "U" }
        return String(first)
    }

    private func save() {
        let trimmed = draftName.trimmingCharacters(in: .whitespaces)
        progress.updateUserName(trimmed)
        isFocused = false
        dismiss()
    }
}
