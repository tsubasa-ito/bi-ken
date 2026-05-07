import SwiftUI

struct HelpView: View {
    @State private var expandedItem: String? = nil

    private let faqs: [(question: String, answer: String)] = [
        (
            "クイズの問題はどこから来ていますか？",
            "ニューヨーク・メトロポリタン美術館（The Met）の公開APIから取得しています。世界中の名作が収録されています。"
        ),
        (
            "XPはどうやって増やしますか？",
            "クイズで正解するたびに5XPを獲得できます。100XP貯まると1レベルアップし、認定書が1枚授与されます。"
        ),
        (
            "ストリーク（連続学習日数）はリセットされますか？",
            "前日に1問も解かなかった日がある場合、ストリークは1からリセットされます。毎日継続して学習することでストリークを維持できます。"
        ),
        (
            "復習モードとは何ですか？",
            "クイズで間違えた問題を集中的に復習できるモードです。ホーム画面の「間違えた問題を復習」から開始できます。"
        ),
        (
            "時代別クイズはどのように機能しますか？",
            "ルネサンス、バロック、印象派、近代美術、日本美術、現代美術の6つの時代から問題を選べます。ホーム画面の「時代別で学ぶ」から選択してください。"
        ),
        (
            "進捗をリセットするとどうなりますか？",
            "レベル、XP、ストリーク、学習履歴、間違えた問題リストがすべて初期値に戻ります。ユーザー名と目標設定は保持されます。この操作は元に戻せません。"
        ),
        (
            "作品の画像が表示されません",
            "インターネット接続を確認してください。Met美術館のAPIにアクセスできない場合は、しばらく待ってから再試行してください。"
        ),
    ]

    var body: some View {
        List {
            Section("よくある質問") {
                ForEach(faqs, id: \.question) { faq in
                    faqItem(faq.question, answer: faq.answer)
                }
            }
            .listRowBackground(Color.appCardBG)

            Section {
                VStack(alignment: .leading, spacing: 6) {
                    Text("それでも解決しない場合")
                        .font(.subheadline.bold())
                        .foregroundStyle(.appText)
                    Text("GitHubリポジトリのIssuesからご報告ください。できる限り対応します。")
                        .font(.footnote)
                        .foregroundStyle(.appTextSecondary)
                }
                .padding(.vertical, 4)
            }
            .listRowBackground(Color.appCardBG)
        }
        .scrollContentBackground(.hidden)
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("ヘルプ")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func faqItem(_ question: String, answer: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    expandedItem = expandedItem == question ? nil : question
                }
            } label: {
                HStack {
                    Text(question)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.appText)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                    Image(systemName: expandedItem == question ? "chevron.up" : "chevron.down")
                        .font(.caption.bold())
                        .foregroundStyle(.appTextTertiary)
                }
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)

            if expandedItem == question {
                Text(answer)
                    .font(.system(size: 13))
                    .foregroundStyle(.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 10)
            }
        }
    }
}
