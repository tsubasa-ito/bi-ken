import SwiftUI

struct HomeView: View {
    @State private var navigationPath = NavigationPath()
    @State private var showEraSheet = false
    @State private var showRandomSheet = false
    private let progress = UserProgress.shared
    @AppStorage("oshiArtworkData") private var oshiArtworkData: Data = Data()

    private var oshiArtworkImageURL: URL? {
        guard !oshiArtworkData.isEmpty else { return nil }
        return (try? JSONDecoder().decode(Artwork.self, from: oshiArtworkData)).flatMap { $0.imageURL }
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    headerSection
                    Divider().overlay(Color.appBorder).padding(.top, 8)

                    VStack(alignment: .leading, spacing: 16) {
                        statsRow
                        modeSection
                        reviewSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationBarHidden(true)
            .navigationDestination(for: QuizMode.self) { mode in
                QuizView(mode: mode)
            }
            .navigationDestination(for: Artwork.self) { artwork in
                ArtworkDetailView(artwork: artwork)
            }
            .sheet(isPresented: $showEraSheet) {
                EraSelectionSheet { era in
                    showEraSheet = false
                    navigationPath.append(QuizMode.era(era))
                }
            }
            .sheet(isPresented: $showRandomSheet) {
                RandomQuizSetupSheet { count in
                    showRandomSheet = false
                    navigationPath.append(QuizMode.random(count))
                }
            }
        }
    }

    // MARK: Header

    private var headerSection: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 2) {
                Text("おかえりなさい")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.appTextSecondary)
                Text("美術検定 4級")
                    .font(.system(size: 22, weight: .bold, design: .serif))
                    .foregroundStyle(.appText)
            }
            Spacer()
            Group {
                if let url = oshiArtworkImageURL {
                    CachedAsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color.appCardBG
                    }
                    .frame(width: 38, height: 38)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.appBorder, lineWidth: 1.5))
                } else {
                    Circle()
                        .fill(Color.appCardBG)
                        .frame(width: 38, height: 38)
                        .overlay(Circle().stroke(Color.appBorder, lineWidth: 1.5))
                        .overlay(
                            Text(avatarInitial)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.appTextSecondary)
                        )
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 52)
        .padding(.bottom, 8)
    }

    private var avatarInitial: String {
        let name = progress.userName.trimmingCharacters(in: .whitespaces)
        guard let first = name.first else { return "U" }
        return String(first)
    }

    // MARK: Stats Row

    private var statsRow: some View {
        HStack(spacing: 8) {
            statCell(value: accuracyText, label: "正答率", bg: Color.appCardBG)
            statCell(value: "\(progress.currentStreak)", label: "連続正解数", bg: Color.appCardBG)
            statCell(value: "\(progress.totalArtworksMet)", label: "挑戦回数", bg: Color.appStreakBG)
        }
    }

    private var accuracyText: String {
        guard progress.totalArtworksMet > 0 else { return "—" }
        let pct = progress.totalCorrectAnswers * 100 / progress.totalArtworksMet
        return "\(max(0, min(100, pct)))%"
    }

    private func statCell(value: String, label: String, bg: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .serif))
                .foregroundStyle(.appText)
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(bg)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.appBorder, lineWidth: 1.5)
        )
    }

    // MARK: Mode Section

    private var modeSection: some View {
        VStack(spacing: 8) {
            sectionSeparator("問題演習")

            modeRow(
                title: "ランダム出題",
                subtitle: "問題数を選んで挑戦",
                badgeText: "?",
                badgeColor: Color.appCardBG,
                bgColor: Color.appCardBG
            ) {
                showRandomSheet = true
            }

            modeRow(
                title: "時代別で学ぶ",
                subtitle: "ルネサンス〜現代まで",
                badgeText: "6",
                badgeColor: Color.appCardBG,
                bgColor: Color.appCardBG
            ) {
                showEraSheet = true
            }

        }
    }

    // MARK: Review Section

    private var reviewSection: some View {
        VStack(spacing: 8) {
            sectionSeparator("復習")

            modeRow(
                title: "間違えた問題を復習",
                subtitle: progress.hasMissedQuestions
                    ? "\(progress.wrongArtworkIDs.count)問が復習待ち"
                    : "苦手を集中攻略",
                badgeText: "\(progress.wrongArtworkIDs.count)",
                badgeColor: Color.appAccent,
                bgColor: Color.appStreakBG
            ) {
                if progress.hasMissedQuestions {
                    navigationPath.append(QuizMode.review)
                }
            }

            modeRow(
                title: "ブックマーク問題",
                subtitle: progress.hasBookmarks
                    ? "\(progress.bookmarkedArtworkIDs.count)作品をブックマーク済み"
                    : "気になる作品を保存して復習",
                badgeText: "🔖",
                badgeColor: Color.appCardBG,
                bgColor: Color.appCardBG
            ) {
                if progress.hasBookmarks {
                    navigationPath.append(QuizMode.bookmark)
                }
            }
        }
    }

    // MARK: Helpers

    private func sectionSeparator(_ title: String) -> some View {
        HStack {
            Rectangle()
                .fill(Color.appTextTertiary.opacity(0.5))
                .frame(height: 0.5)
            Text(title)
                .font(.system(size: 11))
                .foregroundStyle(.appTextTertiary)
            Rectangle()
                .fill(Color.appTextTertiary.opacity(0.5))
                .frame(height: 0.5)
        }
    }

    private func modeRow(
        title: String,
        subtitle: String,
        badgeText: String,
        badgeColor: Color,
        bgColor: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(badgeColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.appBorder, lineWidth: 1.5)
                        )
                        .frame(width: 32, height: 32)
                    Text(badgeText)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.appText)
                }
                .padding(.leading, 14)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold, design: .serif))
                        .foregroundStyle(.appText)
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(.appTextSecondary)
                }
                .padding(.leading, 12)

                Spacer()

                Text("›")
                    .font(.system(size: 24))
                    .foregroundStyle(.appTextTertiary)
                    .padding(.trailing, 14)
            }
            .frame(height: 56)
            .background(bgColor)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.appBorder, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Random Quiz Setup Sheet

struct RandomQuizSetupSheet: View {
    let onSelect: (Int) -> Void
    @Environment(\.dismiss) private var dismiss

    private let options: [(label: String, count: Int)] = [
        ("5問", 5),
        ("10問", 10),
        ("20問", 20),
        ("全問（\(TextbookArtworkData.all.count)問）", TextbookArtworkData.all.count),
    ]

    var body: some View {
        NavigationStack {
            List(options, id: \.count) { option in
                Button {
                    onSelect(option.count)
                } label: {
                    HStack {
                        Text(option.label)
                            .font(.system(size: 17, weight: .semibold, design: .serif))
                            .foregroundStyle(.appText)
                        Spacer()
                        Text("›")
                            .foregroundStyle(.appTextTertiary)
                    }
                    .padding(.vertical, 6)
                }
                .listRowBackground(Color.appCardBG)
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
            .navigationTitle("問題数を選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                        .foregroundStyle(.appPrimary)
                }
            }
        }
    }
}

// MARK: - Era Selection Sheet

struct EraSelectionSheet: View {
    let onSelect: (Era) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(Era.allCases, id: \.self) { era in
                Button {
                    onSelect(era)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(era.japaneseName)
                                .font(.system(size: 16, weight: .semibold, design: .serif))
                                .foregroundStyle(.appText)
                            Text(era.period)
                                .font(.system(size: 12))
                                .foregroundStyle(.appTextSecondary)
                        }
                        Spacer()
                        Text("›")
                            .foregroundStyle(.appTextTertiary)
                    }
                    .padding(.vertical, 4)
                }
                .listRowBackground(Color.appCardBG)
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
            .navigationTitle("時代別で学ぶ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                        .foregroundStyle(.appPrimary)
                }
            }
        }
    }
}
