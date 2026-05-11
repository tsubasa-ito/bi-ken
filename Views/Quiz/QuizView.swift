import SwiftUI

struct QuizView: View {
    let mode: QuizMode
    @State private var vm = QuizViewModel()
    @Environment(\.dismiss) private var dismiss
    @AccessibilityFocusState private var isExplanationFocused: Bool

    var body: some View {
        Group {
            if vm.isLoading {
                loadingView
            } else if let msg = vm.error {
                errorView(message: msg)
            } else if vm.isCompleted {
                QuizResultView(vm: vm, onDismiss: { dismiss() })
            } else if let question = vm.currentQuestion {
                quizContent(question: question)
            }
        }
        .navigationBarHidden(true)
        .task { await vm.load(mode: mode) }
    }

    // MARK: Loading / Error

    private var loadingView: some View {
        VStack(spacing: 16) {
            topBar
            Spacer()
            ProgressView().tint(.appPrimary)
            Text("作品を読み込み中…")
                .font(.system(size: 14))
                .foregroundStyle(.appTextSecondary)
            Spacer()
        }
        .background(Color.appBackground.ignoresSafeArea())
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            topBar
            Spacer()
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: 40))
                .foregroundStyle(.appIncorrect)
            Text(message)
                .font(.headline)
                .foregroundStyle(.appText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button("再試行") { Task { await vm.load(mode: mode) } }
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 10)
                .background(Color.appPrimary)
                .clipShape(Capsule())
            Spacer()
        }
        .background(Color.appBackground.ignoresSafeArea())
    }

    // MARK: Quiz Content

    private func quizContent(question: QuizQuestion) -> some View {
        VStack(spacing: 0) {
            topBar
            topBarBorder

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("この作品の作者は？")
                        .font(.system(size: 20, weight: .semibold, design: .serif))
                        .foregroundStyle(.appText)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 12)

                    artFrame(question: question)

                    hintText(question: question)
                        .padding(.top, 6)
                        .padding(.bottom, 12)

                    optionsSection(question: question)

                    if vm.showResult {
                        explanationPanel(question: question)
                            .padding(.top, 12)
                            .accessibilityFocused($isExplanationFocused)
                            .onAppear {
                                isExplanationFocused = true
                            }
                        nextButton
                            .padding(.top, 12)
                    }
                }
                .padding(.bottom, 32)
            }
        }
        .background(Color.appBackground.ignoresSafeArea())
    }

    // MARK: Top Bar

    private var topBar: some View {
        ZStack {
            Color.appBackground

            HStack(spacing: 0) {
                Button { dismiss() } label: {
                    ZStack {
                        Circle()
                            .fill(Color.clear)
                            .frame(width: 36, height: 36)
                        Text("×")
                            .font(.system(size: 20))
                            .foregroundStyle(.appText)
                    }
                }
                .padding(.leading, 12)
                .accessibilityLabel("クイズを閉じる")

                Spacer()

                VStack(spacing: 4) {
                    Text("問題 \(vm.currentIndex + 1) / \(vm.totalQuestions)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.appTextSecondary)

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
                                .frame(width: max(0, geo.size.width * vm.progress), height: 8)
                                .animation(.easeInOut, value: vm.progress)
                        }
                    }
                    .frame(width: 180, height: 8)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("問題の進捗")
                .accessibilityValue("\(vm.currentIndex + 1) / \(vm.totalQuestions)")

                Spacer()

                streakChip
                    .padding(.trailing, 12)
            }
            .frame(height: 60)
            .padding(.top, 44)
        }
        .frame(height: 104)
    }

    private var topBarBorder: some View {
        Rectangle()
            .fill(Color.appBorder)
            .frame(height: 1.5)
    }

    private var streakChip: some View {
        HStack(spacing: 4) {
            Text("🔥")
                .font(.system(size: 13))
            Text("\(UserProgress.shared.currentStreak)")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.appText)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.appStreakBG)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.appBorder, lineWidth: 1.5)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(UserProgress.shared.currentStreak)日連続学習中")
    }

    // MARK: Art Frame

    private func artFrame(question: QuizQuestion) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.appCardBG)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.appBorder, lineWidth: 1.5)
                )

            if let imageURL = question.artwork.imageURL {
                CachedAsyncImage(url: imageURL) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    ProgressView().tint(.appPrimary)
                }
                .frame(height: vm.showResult ? 180 : 240)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .padding(10)
                .accessibilityLabel("作品の画像")
                .accessibilityHint("この作品の作者を選んでください")
            } else {
                Text("『\(question.artwork.displayTitle)』")
                    .font(.system(size: 22, weight: .semibold, design: .serif))
                    .foregroundStyle(.appText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 32)
                    .accessibilityLabel("作品のタイトル: \(question.artwork.displayTitle)")
                    .accessibilityHint("この作品の作者を選んでください")
            }
        }
        .frame(minHeight: vm.showResult ? 160 : 220)
        .padding(.horizontal, 20)
        .animation(.easeInOut(duration: 0.3), value: vm.showResult)
    }

    // MARK: Hint

    private func hintText(question: QuizQuestion) -> some View {
        HStack {
            Spacer()
            let yearStr = question.artwork.year.map { "c.\($0)" } ?? ""
            let mediumStr = question.artwork.shortMediumJa
            let hint = [yearStr, mediumStr].filter { !$0.isEmpty }.joined(separator: " / ")
            if !hint.isEmpty {
                Text(hint)
                    .font(.system(size: 11))
                    .foregroundStyle(.appTextTertiary)
                    .padding(.trailing, 20)
            }
        }
    }

    // MARK: Options

    private func optionsSection(question: QuizQuestion) -> some View {
        VStack(spacing: 8) {
            ForEach(question.options.indices, id: \.self) { i in
                let option = question.options[i]
                let label = ["A", "B", "C", "D"][safe: i] ?? "?"
                Button { vm.selectAnswer(option) } label: {
                    choiceRow(option: option, label: label, question: question)
                }
                .disabled(vm.showResult)
                .buttonStyle(.plain)
                .animation(.easeInOut(duration: 0.2), value: vm.showResult)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(choiceAccessibilityLabel(option: option, label: label, question: question))
            }
        }
        .padding(.horizontal, 20)
    }

    private func choiceAccessibilityLabel(option: String, label: String, question: QuizQuestion) -> String {
        guard vm.showResult else { return "選択肢\(label): \(option)" }
        if option == question.correctAnswer { return "正解: 選択肢\(label), \(option)" }
        if vm.selectedAnswer == option { return "不正解: 選択肢\(label), \(option)" }
        return "選択肢\(label): \(option)"
    }

    private func choiceRow(option: String, label: String, question: QuizQuestion) -> some View {
        let state = choiceState(option, question: question)
        return HStack(spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(state.badgeFill)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(state.borderColor, lineWidth: 1.5)
                    )
                    .frame(width: 28, height: 28)
                Text(label)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(state.textColor)
            }
            .padding(.leading, 14)

            Text(option)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(state.textColor)
                .padding(.leading, 14)

            Spacer()
        }
        .frame(height: 48)
        .background(state.bgColor)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(state.borderColor, lineWidth: 1.5)
        )
    }

    private struct ChoiceStyle {
        var bgColor: Color
        var badgeFill: Color
        var borderColor: Color
        var textColor: Color
    }

    private func choiceState(_ option: String, question: QuizQuestion) -> ChoiceStyle {
        guard vm.showResult else {
            return .init(bgColor: .appCardBG, badgeFill: .appCardBG, borderColor: .appBorder, textColor: .appText)
        }
        if option == question.correctAnswer {
            return .init(bgColor: .appCorrectBG, badgeFill: .appCorrect, borderColor: .appCorrect, textColor: .appCorrect)
        }
        if vm.selectedAnswer == option {
            return .init(bgColor: .appIncorrectBG, badgeFill: .appIncorrect, borderColor: .appIncorrect, textColor: .appIncorrect)
        }
        return .init(bgColor: .appCardBG, badgeFill: .appCardBG, borderColor: Color(hex: "c8c6bf"), textColor: .appTextTertiary)
    }

    // MARK: Explanation Panel

    private func explanationPanel(question: QuizQuestion) -> some View {
        let artwork = question.artwork
        let examPoint = examPointText(artwork)
        let bookmarked = UserProgress.shared.isBookmarked(artwork.id)
        return HStack(spacing: 0) {
            Rectangle()
                .fill(Color.appAccent)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 4) {
                Text("── 解説 ──")
                    .font(.system(size: 10))
                    .foregroundStyle(.appTextSecondary)

                Text("『\(artwork.displayTitle)』\(artwork.year.map { " (c.\($0))" } ?? "")")
                    .font(.system(size: 14, weight: .semibold, design: .serif))
                    .foregroundStyle(.appText)

                Text("作者：\(artwork.displayArtist)")
                    .font(.system(size: 12))
                    .foregroundStyle(.appTextSecondary)

                Text(shortDescription(artwork))
                    .font(.system(size: 12))
                    .foregroundStyle(.appTextSecondary)

                Text("★ 検定ポイント：\(examPoint)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.appPrimary)
            }
            .padding(12)

            Spacer(minLength: 0)

            Button {
                UserProgress.shared.toggleBookmark(artworkID: artwork.id)
            } label: {
                Image(systemName: bookmarked ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 18))
                    .foregroundStyle(bookmarked ? .appPrimary : .appTextSecondary)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(bookmarked ? "ブックマーク済み" : "ブックマークに追加")
            .padding(.trailing, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.appStreakBG)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.appBorder, lineWidth: 1.5)
        )
        .padding(.horizontal, 20)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private func shortDescription(_ artwork: Artwork) -> String {
        let era = artwork.era.japaneseName
        let medium = artwork.shortMediumJa
        var parts: [String] = []
        if !medium.isEmpty { parts.append("\(medium)で描かれた") }
        parts.append("\(era)の代表的な作品")
        return parts.joined()
    }

    private func examPointText(_ artwork: Artwork) -> String {
        var parts: [String] = []
        parts.append(artwork.era.japaneseName)
        if !artwork.movement.isEmpty && artwork.movement != artwork.era.japaneseName {
            parts.append(artwork.movement)
        }
        return parts.joined(separator: " / ")
    }

    // MARK: Next Button

    private var nextButton: some View {
        Button(action: vm.nextQuestion) {
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.appText)
                    .frame(height: 50)
                    .offset(y: 2)
                HStack {
                    Text(vm.currentIndex < vm.totalQuestions - 1 ? "次の問題 →" : "結果を見る")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.appPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.appBorder, lineWidth: 1.5)
                )
            }
        }
        .padding(.horizontal, 20)
        .accessibilityLabel(vm.currentIndex < vm.totalQuestions - 1 ? "次の問題へ" : "結果を見る")
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.spring(duration: 0.3), value: vm.showResult)
    }
}
