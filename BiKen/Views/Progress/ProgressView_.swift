import SwiftUI

struct ProgressView_: View {
    private let progress = UserProgress.shared

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                customHeader

                Rectangle()
                    .fill(Color.appBorder)
                    .frame(height: 1.5)

                ScrollView {
                    VStack(spacing: 16) {
                        levelCard
                        statsRow
                        eraProgressSection
                        heatmapSection
                        continueButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationBarHidden(true)
            .navigationDestination(for: QuizMode.self) { mode in
                QuizView(mode: mode)
            }
        }
    }

    // MARK: Header

    private var customHeader: some View {
        ZStack {
            Color.appBackground
            Text("学習の記録")
                .font(.system(size: 18, weight: .semibold, design: .serif))
                .foregroundStyle(.appText)
        }
        .frame(height: 104)
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
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.appBorder, lineWidth: 1.5)
        )
    }

    // MARK: Stats Row

    private var statsRow: some View {
        HStack(spacing: 8) {
            statCell(value: "\(progress.currentStreak)", label: "連続日数", bg: Color.appStreakBG)
            statCell(value: "\(progress.totalArtworksMet)", label: "解いた問題", bg: Color.appCardBG)
            statCell(value: accuracyText, label: "正答率", bg: Color.appCardBG)
        }
    }

    private var accuracyText: String { "—" }

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

    // MARK: Era Progress

    private var eraProgressSection: some View {
        VStack(spacing: 12) {
            HStack {
                Rectangle().fill(Color.appTextTertiary.opacity(0.5)).frame(height: 0.5)
                Text("時代別の進捗")
                    .font(.system(size: 11))
                    .foregroundStyle(.appTextTertiary)
                Rectangle().fill(Color.appTextTertiary.opacity(0.5)).frame(height: 0.5)
            }

            ForEach(Era.allCases, id: \.self) { era in
                eraRow(era: era)
            }
        }
    }

    private func eraRow(era: Era) -> some View {
        let pct = eraPercentage(era)
        return HStack(spacing: 8) {
            Text(era.japaneseName)
                .font(.system(size: 13, design: .serif))
                .foregroundStyle(.appText)
                .frame(width: 72, alignment: .leading)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.appCardBG)
                        .frame(height: 10)
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.appPrimary)
                        .frame(width: max(0, geo.size.width * CGFloat(pct) / 100), height: 10)
                }
            }
            .frame(height: 10)

            Text("\(pct)%")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.appTextSecondary)
                .frame(width: 36, alignment: .trailing)
        }
    }

    private func eraPercentage(_ era: Era) -> Int { 0 }

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
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 28), spacing: 4) {
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

    private func last28Days() -> [String] {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        let today = Date()
        return (0..<28).reversed().compactMap { offset in
            Calendar.current.date(byAdding: .day, value: -offset, to: today).map { formatter.string(from: $0) }
        }
    }

    // MARK: Continue Button

    private var continueButton: some View {
        NavigationLink(value: QuizMode.random) {
            Text("学習を続ける")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.appPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.appBorder, lineWidth: 1.5)
                )
        }
        .buttonStyle(.plain)
    }
}
