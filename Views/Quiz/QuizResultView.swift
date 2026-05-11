import SwiftUI

struct QuizResultView: View {
    let vm: QuizViewModel
    let onDismiss: () -> Void
    @State private var didRecord = false
    @State private var showReview = false

    private var incorrectCount: Int { vm.answerRecords.filter { !$0.isCorrect }.count }
    private var incorrectIDs: [String] {
        vm.answerRecords.filter { !$0.isCorrect }.map { $0.question.artwork.id }
    }
    private var canShowReviewButton: Bool {
        guard incorrectCount > 0 else { return false }
        if case .specificIDs = vm.mode { return false }
        return true
    }

    var body: some View {
        VStack(spacing: 0) {
            headerBar
            headerBorder

            ScrollView {
                VStack(spacing: 16) {
                    congratsSection
                    statsGrid
                    resultGrid
                    actionButtons
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showReview) {
            QuizView(mode: .specificIDs(incorrectIDs))
        }
        .onAppear {
            guard !didRecord else { return }
            didRecord = true
            UserProgress.shared.recordQuizResult(correct: vm.correctCount, total: vm.totalQuestions)
        }
    }

    // MARK: Header

    private var headerBar: some View {
        ZStack {
            Color.appBackground
            HStack {
                Button(action: onDismiss) {
                    Text("×")
                        .font(.system(size: 20))
                        .foregroundStyle(.appText)
                        .frame(width: 36, height: 36)
                }
                .padding(.leading, 12)
                .accessibilityLabel("閉じる")

                Spacer()

                Text("セット完了")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.appText)

                Spacer()

                Color.clear.frame(width: 36, height: 36)
                    .padding(.trailing, 12)
            }
        }
        .frame(height: 104)
    }

    private var headerBorder: some View {
        Rectangle()
            .fill(Color.appBorder)
            .frame(height: 1.5)
    }

    // MARK: Congrats

    private var congratsSection: some View {
        VStack(spacing: 4) {
            Text("おつかれさま！")
                .font(.system(size: 26, weight: .bold, design: .serif))
                .foregroundStyle(.appText)
                .padding(.top, 16)

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(vm.correctCount)")
                    .font(.system(size: 72, weight: .bold, design: .serif))
                    .foregroundStyle(.appText)
                Text("/ \(vm.totalQuestions)")
                    .font(.system(size: 28, design: .serif))
                    .foregroundStyle(.appTextTertiary)
            }

            let pct = vm.totalQuestions > 0
                ? Int(Double(vm.correctCount) / Double(vm.totalQuestions) * 100)
                : 0
            Text("正答率 \(pct)%")
                .font(.system(size: 13))
                .foregroundStyle(.appTextSecondary)
        }
    }

    // MARK: Stats Grid

    private var statsGrid: some View {
        HStack(spacing: 12) {
            statCard(
                value: "\(vm.correctCount)問",
                label: "正解",
                bg: Color.appCardBG
            )
            statCard(
                value: "🔥 \(UserProgress.shared.currentStreak)日",
                label: "本日のストリーク",
                bg: Color.appStreakBG,
                accessibilityLabel: "\(UserProgress.shared.currentStreak)日連続、本日のストリーク"
            )
        }
    }

    private func statCard(value: String, label: String, bg: Color, accessibilityLabel: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .serif))
                .foregroundStyle(.appText)
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(.appTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(bg)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.appBorder, lineWidth: 1.5)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel ?? "\(value) \(label)")
    }

    // MARK: Result Grid

    private var resultGrid: some View {
        VStack(spacing: 8) {
            HStack {
                Rectangle().fill(Color.appTextTertiary.opacity(0.5)).frame(height: 0.5)
                Text("結果一覧")
                    .font(.system(size: 11))
                    .foregroundStyle(.appTextTertiary)
                Rectangle().fill(Color.appTextTertiary.opacity(0.5)).frame(height: 0.5)
            }

            ForEach(vm.answerRecords.indices, id: \.self) { i in
                resultRow(record: vm.answerRecords[i])
            }
        }
    }

    private func resultRow(record: AnswerRecord) -> some View {
        let artwork = record.question.artwork
        let bookmarked = UserProgress.shared.isBookmarked(artwork.id)
        return HStack(spacing: 12) {
            Text(record.isCorrect ? "○" : "×")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(record.isCorrect ? .appCorrect : .appIncorrect)
                .frame(width: 24)
                .accessibilityLabel(record.isCorrect ? "正解" : "不正解")

            VStack(alignment: .leading, spacing: 2) {
                Text(artwork.displayTitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.appText)
                    .lineLimit(1)
                Text(artwork.displayArtist)
                    .font(.system(size: 11))
                    .foregroundStyle(.appTextSecondary)
                    .lineLimit(1)
            }

            Spacer()

            Button {
                UserProgress.shared.toggleBookmark(artworkID: artwork.id)
            } label: {
                Image(systemName: bookmarked ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 16))
                    .foregroundStyle(bookmarked ? .appPrimary : .appTextSecondary)
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(bookmarked ? "ブックマーク済み" : "ブックマークに追加")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(record.isCorrect ? Color.appCorrectBG : Color.appIncorrectBG)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.appBorder, lineWidth: 1.5)
        )
    }

    // MARK: Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 12) {
            if canShowReviewButton {
                Button { showReview = true } label: {
                    Text("間違えた\(incorrectCount)問を復習する")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.appText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.appAccent)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.appBorder, lineWidth: 1.5)
                        )
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 12) {
                Button(action: onDismiss) {
                    Text("もう一度")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.appText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.appCardBG)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.appBorder, lineWidth: 1.5)
                        )
                }
                .buttonStyle(.plain)

                Button {
                    AdService.shared.showInterstitial(onDismiss: onDismiss)
                } label: {
                    Text("ホームへ")
                        .font(.system(size: 14, weight: .medium))
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
    }
}
