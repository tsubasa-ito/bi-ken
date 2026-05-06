import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                List {
                    Section("アカウント") {
                        settingsRow(icon: "person.circle.fill", title: "プロフィール", color: .appPrimary)
                        settingsRow(icon: "bell.fill", title: "通知", color: .orange)
                    }
                    .listRowBackground(Color.appSurface)

                    Section("学習") {
                        settingsRow(icon: "target", title: "日標設定", color: .appSuccess)
                        settingsRow(icon: "clock.fill", title: "学習リマインダー", color: .purple)
                        settingsRow(icon: "arrow.clockwise", title: "進捗をリセット", color: .appError)
                    }
                    .listRowBackground(Color.appSurface)

                    Section("アプリ") {
                        settingsRow(icon: "info.circle.fill", title: "アプリについて", color: .appTextSecondary)
                        settingsRow(icon: "star.fill", title: "レビューを書く", color: .yellow)
                        settingsRow(icon: "questionmark.circle.fill", title: "ヘルプ", color: .cyan)
                    }
                    .listRowBackground(Color.appSurface)

                    Section {
                        HStack {
                            Spacer()
                            VStack(spacing: 4) {
                                Text("美術検定")
                                    .font(.headline.bold())
                                    .foregroundStyle(.white)
                                Text("バージョン 1.0.0")
                                    .font(.caption)
                                    .foregroundStyle(.appTextSecondary)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                    .listRowBackground(Color.clear)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private func settingsRow(icon: String, title: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(color)
                .frame(width: 28, height: 28)

            Text(title)
                .foregroundStyle(.white)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundStyle(.appTextSecondary)
        }
        .padding(.vertical, 4)
    }
}
