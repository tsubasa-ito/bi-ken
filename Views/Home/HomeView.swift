import SwiftUI

struct HomeView: View {
    @State private var vm = HomeViewModel()
    @State private var navigationPath = NavigationPath()
    @State private var showEraSheet = false
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
                        streakBox
                        levelCard
                        statsRow
                        ctaCard
                        modeSection
                        heatmapSection
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
        }
        .task { await vm.load() }
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

    // MARK: Streak Box

    private var streakBox: some View {
        HStack(spacing: 0) {
            Text("🔥")
                .font(.system(size: 22))
                .padding(.leading, 14)
            VStack(alignment: .leading, spacing: 2) {
                Text("\(progress.currentStreak)日連続学習中！")
                    .font(.system(size: 16, weight: .semibold, design: .serif))
                    .foregroundStyle(.appText)
                Text(dailyGoalText)
                    .font(.system(size: 11))
                    .foregroundStyle(.appTextSecondary)
            }
            .padding(.leading, 10)
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.appPrimary)
                    .frame(width: 32, height: 32)
                Text("\(progress.currentXP)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
            }
            .padding(.trailing, 14)
        }
        .frame(height: 64)
        .background(Color.appStreakBG)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.appBorder, lineWidth: 1.5)
        )
    }

    private var avatarInitial: String {
        let name = progress.userName.trimmingCharacters(in: .whitespaces)
        guard let first = name.first else { return "U" }
        return String(first)
    }

    private var dailyGoalText: String {
        let goal = progress.dailyGoal
        let done = progress.todayArtworksMet
        let remaining = goal - done
        if remaining <= 0 {
            return "今日の目標 \(goal)問 達成！"
        }
        return "あと\(remaining)問で今日の目標 \(goal)問 達成"
    }

    // MARK: CTA Card

    private var ctaCard: some View {
        Button {
            navigationPath.append(QuizMode.random)
        } label: {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.appPrimary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.appBorder, lineWidth: 1.5)
                    )

                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("TODAY'S CHALLENGE")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.white.opacity(0.8))
                            .padding(.top, 14)
                        Text("今日の一問")
                            .font(.system(size: 22, weight: .bold, design: .serif))
                            .foregroundStyle(.white)
                            .padding(.top, 2)
                        Text("1分 · 10XP")
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.73))
                            .padding(.top, 12)
                        ctaButton
                            .padding(.top, 8)
                    }
                    .padding(.leading, 16)

                    Spacer()

                    artworkThumbnail
                        .padding(.trailing, 14)
                        .padding(.top, 14)
                }
            }
            .frame(height: 128)
        }
        .buttonStyle(.plain)
    }

    private var ctaButton: some View {
        HStack(spacing: 4) {
            Text("挑戦する →")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.appText)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.appAccent)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.appBorder, lineWidth: 1.5)
        )
    }

    private var artworkThumbnail: some View {
        Group {
            if let artwork = vm.dailyArtwork {
                CachedAsyncImage(url: artwork.imageURL) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.white.opacity(0.13)
                }
                .frame(width: 80, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 6))
            } else {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.white.opacity(0.13))
                    .frame(width: 80, height: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.white.opacity(0.47), lineWidth: 1.5)
                    )
            }
        }
    }

    // MARK: Mode Section

    private var modeSection: some View {
        VStack(spacing: 8) {
            HStack {
                Rectangle()
                    .fill(Color.appTextTertiary.opacity(0.5))
                    .frame(height: 0.5)
                Text("学習モード")
                    .font(.system(size: 11))
                    .foregroundStyle(.appTextTertiary)
                Rectangle()
                    .fill(Color.appTextTertiary.opacity(0.5))
                    .frame(height: 0.5)
            }

            modeRow(
                title: "10問チャレンジ",
                subtitle: "基本セット · 4択",
                badgeText: "10",
                badgeColor: Color.appCardBG,
                bgColor: Color.appCardBG
            ) {
                navigationPath.append(QuizMode.random)
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
                navigationPath.append(QuizMode.bookmark)
            }

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

    // MARK: Level Card

    private var levelCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("現在のレベル")
                .font(.system(size: 11))
                .foregroundStyle(.appTextSecondary)

            HStack(alignment: .bottom, spacing: 12) {
                Text("Lv.\(progress.level)")
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundStyle(.appText)
                Text(progress.levelTitle)
                    .font(.system(size: 14))
                    .foregroundStyle(.appTextSecondary)
                    .padding(.bottom, 4)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.appCardBG)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.appBorder, lineWidth: 1.5)
                        )
                        .frame(height: 8)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.appPrimary)
                        .frame(width: max(0, geo.size.width * CGFloat(progress.currentXP) / 100), height: 8)
                }
            }
            .frame(height: 8)

            HStack {
                Text("\(progress.currentXP) / 100 XP")
                    .font(.system(size: 10))
                    .foregroundStyle(.appTextSecondary)
                Spacer()
                Text("次：\(progress.nextLevelTitle)")
                    .font(.system(size: 10))
                    .foregroundStyle(.appTextSecondary)
            }
        }
        .padding(14)
        .background(Color.appCardBG)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.appBorder, lineWidth: 1.5)
        )
    }

    // MARK: Stats Row

    private var statsRow: some View {
        HStack(spacing: 8) {
            statCell(value: "\(progress.totalArtworksMet)", label: "解いた問題", bg: Color.appCardBG)
            statCell(value: accuracyText, label: "正答率", bg: Color.appCardBG)
            statCell(value: "\(progress.totalCertificates)", label: "証書", bg: Color.appStreakBG)
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

    // MARK: Heatmap

    private var heatmapSection: some View {
        VStack(spacing: 8) {
            HStack {
                Rectangle().fill(Color.appTextTertiary.opacity(0.5)).frame(height: 0.5)
                Text("学習履歴（直近4週間）")
                    .font(.system(size: 11))
                    .foregroundStyle(.appTextTertiary)
                Rectangle().fill(Color.appTextTertiary.opacity(0.5)).frame(height: 0.5)
            }

            let dates = last28Days()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                ForEach(dates, id: \.self) { dateStr in
                    heatCell(dateStr: dateStr)
                }
            }
        }
    }

    private func heatCell(dateStr: String) -> some View {
        let studied = progress.studyDateStrings.contains(dateStr)
        let color: Color = studied ? .appPrimary : .appCardBG
        return RoundedRectangle(cornerRadius: 2)
            .fill(color)
            .frame(height: 9)
    }

    private static let dayFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter
    }()

    private func last28Days() -> [String] {
        let today = Date()
        return (0..<28).reversed().compactMap { offset -> String? in
            guard let date = Calendar.current.date(byAdding: .day, value: -offset, to: today) else {
                assertionFailure("Calendar.date(byAdding:) returned nil for offset \(offset)")
                return nil
            }
            return Self.dayFormatter.string(from: date)
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
