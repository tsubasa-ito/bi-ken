import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                customHeader

                Rectangle()
                    .fill(Color.appBorder)
                    .frame(height: 1.5)

                List {
                    Section("アカウント") {
                        settingsRow(icon: "person.circle.fill", title: "プロフィール", color: .appPrimary)
                        settingsRow(icon: "bell.fill", title: "通知", color: .orange)
                    }
                    .listRowBackground(Color.appCardBG)

                    Section("学習") {
                        settingsRow(icon: "target", title: "日標設定", color: .appCorrect)
                        settingsRow(icon: "clock.fill", title: "学習リマインダー", color: .purple)
                        settingsRow(icon: "arrow.clockwise", title: "進捗をリセット", color: .appIncorrect)
                    }
                    .listRowBackground(Color.appCardBG)

                    Section("アプリ") {
                        settingsRow(icon: "info.circle.fill", title: "アプリについて", color: .appTextSecondary)
                        settingsRow(icon: "star.fill", title: "レビューを書く", color: .yellow)
                        settingsRow(icon: "questionmark.circle.fill", title: "ヘルプ", color: .cyan)
                    }
                    .listRowBackground(Color.appCardBG)

                    Section {
                        HStack {
                            Spacer()
                            VStack(spacing: 4) {
                                Text("美術検定")
                                    .font(.headline.bold())
                                    .foregroundStyle(.appText)
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
                .background(Color.appBackground)
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }

    private var customHeader: some View {
        ZStack {
            Color.appBackground
            Text("設定")
                .font(.system(size: 18, weight: .semibold, design: .serif))
                .foregroundStyle(.appText)
        }
        .frame(height: 104)
    }

    private func settingsRow(icon: String, title: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(color)
                .frame(width: 28, height: 28)

            Text(title)
                .foregroundStyle(.appText)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundStyle(.appTextTertiary)
        }
        .padding(.vertical, 4)
    }
}
