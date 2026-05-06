import SwiftUI

struct QuizView: View {
    let eraID: String
    @State private var vm = QuizViewModel()
    @Environment(\.dismiss) private var dismiss

    private var era: Era? {
        Era.allCases.first { $0.quizID == eraID }
    }

    var body: some View {
        Group {
            if vm.isLoading {
                loadingView
            } else if let errorMsg = vm.error {
                errorView(message: errorMsg)
            } else if vm.isCompleted {
                QuizResultView(vm: vm, onDismiss: { dismiss() })
            } else if let question = vm.currentQuestion {
                quizContent(question: question)
            }
        }
        .navigationBarHidden(true)
        .task { await vm.load(era: era) }
    }

    // MARK: Loading

    private var loadingView: some View {
        VStack(spacing: 16) {
            headerBar
            Spacer()
            ProgressView().tint(.appPrimary).scaleEffect(1.5)
            Text("作品を読み込み中...").font(.headline).foregroundStyle(.primary)
            Text("メトロポリタン美術館から取得しています")
                .font(.caption).foregroundStyle(.appTextSecondary)
            Spacer()
        }
        .background(Color.appBackground.ignoresSafeArea())
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            headerBar
            Spacer()
            Image(systemName: "exclamationmark.circle").font(.system(size: 48)).foregroundStyle(.appError)
            Text(message).font(.headline).foregroundStyle(.primary)
            Button("再試行") { Task { await vm.load(era: era) } }
                .buttonStyle(.borderedProminent).tint(.appPrimary)
            Spacer()
        }
        .background(Color.appBackground.ignoresSafeArea())
    }

    // MARK: Quiz Content

    private func quizContent(question: QuizQuestion) -> some View {
        VStack(spacing: 0) {
            headerBar

            ScrollView {
                VStack(spacing: 16) {
                    progressBar
                    artworkFrame(question: question)
                    questionSection(question: question)
                    optionsSection(question: question)
                    if vm.showResult {
                        nextButton(question: question)
                    }
                }
                .padding(.bottom, 32)
            }

            footerBar
        }
        .background(Color(.systemBackground).ignoresSafeArea())
    }

    private var headerBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.title3)
                    .foregroundStyle(.primary)
                    .frame(width: 40, height: 40)
            }
            Spacer()
            Text("美術検定")
                .font(.caption.bold())
                .foregroundStyle(.primary)
                .tracking(1)
                .textCase(.uppercase)
            Spacer()
            if !vm.isLoading && vm.error == nil {
                Image(systemName: "info.circle")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .frame(width: 40, height: 40)
            } else {
                Color.clear.frame(width: 40, height: 40)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .overlay(alignment: .bottom) {
            Divider()
        }
    }

    private var progressBar: some View {
        VStack(spacing: 4) {
            HStack {
                Text("進捗").font(.caption.bold()).foregroundStyle(.secondary).tracking(1)
                Spacer()
                Text("\(vm.currentIndex + 1) / \(vm.totalQuestions)")
                    .font(.caption.bold()).foregroundStyle(.appPrimary)
            }
            .padding(.horizontal, 20)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(.systemGray5)).frame(height: 6)
                    Capsule().fill(Color.appPrimary)
                        .frame(width: geo.size.width * vm.progress, height: 6)
                        .animation(.easeInOut, value: vm.progress)
                }
            }
            .frame(height: 6)
            .padding(.horizontal, 20)
        }
        .padding(.top, 12)
    }

    private func artworkFrame(question: QuizQuestion) -> some View {
        VStack {
            AsyncImage(url: question.artwork.imageURL) { image in
                image.resizable().scaledToFit()
            } placeholder: {
                Color(.systemGray6)
                    .overlay { ProgressView().tint(.appPrimary) }
            }
            .frame(height: 280)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal, 20)
        .padding(12)
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 20)
    }

    private func questionSection(question: QuizQuestion) -> some View {
        VStack(spacing: 6) {
            if vm.showResult {
                Text("『\(question.artwork.displayTitle)』")
                    .font(.title3.bold())
                    .multilineTextAlignment(.center)
                Text("作者: \(question.correctAnswer)")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.appPrimary)
            } else {
                Text(question.question)
                    .font(.title3.bold())
                    .multilineTextAlignment(.center)
                Text("下の選択肢から正しい作者を選んでください")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .italic()
            }
        }
        .padding(.horizontal, 20)
    }

    private func optionsSection(question: QuizQuestion) -> some View {
        VStack(spacing: 10) {
            ForEach(question.options.indices, id: \.self) { i in
                let option = question.options[i]
                Button { vm.selectAnswer(option) } label: {
                    Text(option)
                        .font(.subheadline.weight(.medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(optionBackground(option, question: question))
                        .foregroundStyle(optionForeground(option, question: question))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(optionBorder(option, question: question), lineWidth: 2))
                }
                .disabled(vm.showResult)
                .animation(.easeInOut(duration: 0.2), value: vm.showResult)
            }
        }
        .padding(.horizontal, 20)
    }

    private func optionBackground(_ option: String, question: QuizQuestion) -> Color {
        guard vm.showResult else {
            return vm.selectedAnswer == option
                ? Color.appPrimary.opacity(0.08) : Color(.systemBackground)
        }
        if option == question.correctAnswer { return Color.appSuccess.opacity(0.08) }
        if vm.selectedAnswer == option { return Color.appError.opacity(0.08) }
        return Color(.systemBackground)
    }

    private func optionBorder(_ option: String, question: QuizQuestion) -> Color {
        guard vm.showResult else {
            return vm.selectedAnswer == option ? .appPrimary : Color(.systemGray4)
        }
        if option == question.correctAnswer { return .appSuccess }
        if vm.selectedAnswer == option { return .appError }
        return Color(.systemGray4)
    }

    private func optionForeground(_ option: String, question: QuizQuestion) -> Color {
        guard vm.showResult else {
            return vm.selectedAnswer == option ? .appPrimary : Color(.label)
        }
        if option == question.correctAnswer { return .appSuccess }
        if vm.selectedAnswer == option { return .appError }
        return Color(.label)
    }

    private func nextButton(question: QuizQuestion) -> some View {
        Button(action: vm.nextQuestion) {
            HStack(spacing: 8) {
                Text(vm.currentIndex < vm.totalQuestions - 1 ? "次の問題へ" : "結果を見る")
                Image(systemName: "arrow.right")
            }
            .font(.subheadline.bold())
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.appPrimary, in: Capsule())
        }
        .padding(.horizontal, 20)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.spring(duration: 0.3), value: vm.showResult)
    }

    private var footerBar: some View {
        HStack {
            Spacer()
            Button { } label: { Image(systemName: "bookmark").font(.title3).foregroundStyle(.secondary) }
            Button { } label: { Image(systemName: "square.and.arrow.up").font(.title3).foregroundStyle(.secondary) }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .overlay(alignment: .top) { Divider() }
        .background(Color(.systemBackground))
    }
}
