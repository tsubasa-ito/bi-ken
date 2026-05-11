import SwiftUI

struct AboutView: View {
    var body: some View {
        List {
            Section {
                appHeader
            }
            .listRowBackground(Color.clear)

            Section("このアプリについて") {
                infoRow(label: "対象", value: "美術検定4級")
                infoRow(label: "データソース", value: "Wikipedia")
            }
            .listRowBackground(Color.appCardBG)

            Section("機能") {
                featureRow(icon: "paintpalette.fill", color: .appPrimary, text: "名作\(TextbookArtworkData.all.count)点を収録")
                featureRow(icon: "brain.head.profile", color: .purple, text: "4択クイズで美術知識をトレーニング")
                featureRow(icon: "flame.fill", color: .orange, text: "ストリーク機能で継続学習をサポート")
            }
            .listRowBackground(Color.appCardBG)

            Section("データ") {
                infoRow(label: "画像", value: "Wikipedia（各作品のライセンスに準拠）")
            }
            .listRowBackground(Color.appCardBG)
        }
        .scrollContentBackground(.hidden)
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("アプリについて")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var appHeader: some View {
        HStack {
            Spacer()
            VStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.appPrimary)
                    .frame(width: 72, height: 72)
                    .overlay(
                        Text("美")
                            .font(.system(size: 36, weight: .bold, design: .serif))
                            .foregroundStyle(.white)
                    )
                Text("美術検定4級 名画問題集")
                    .font(.system(size: 20, weight: .bold, design: .serif))
                    .foregroundStyle(.appText)
                Text("美術の知識を楽しく学ぼう")
                    .font(.system(size: 13))
                    .foregroundStyle(.appTextSecondary)
            }
            .padding(.vertical, 16)
            Spacer()
        }
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.appText)
            Spacer()
            Text(value)
                .foregroundStyle(.appTextSecondary)
                .multilineTextAlignment(.trailing)
        }
    }

    private func featureRow(icon: String, color: Color, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 22)
            Text(text)
                .foregroundStyle(.appText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 2)
    }
}
