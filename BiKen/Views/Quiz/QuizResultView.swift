import SwiftUI

struct QuizResultView: View {
    let vm: QuizViewModel
    let onDismiss: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var didRecord = false

    private let circleSize: CGFloat = 160
    private let strokeWidth: CGFloat = 10

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "0D1117"), Color(hex: "161B22")],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                resultHeader

                ScrollView {
                    VStack(spacing: 24) {
                        scoreCircle
                        scoreMessage
                        progressCard
                        artworksSection
                        actionButtons
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            guard !didRecord else { return }
            didRecord = true
            UserProgress.shared.recordQuizResult(correct: vm.correctCount, total: vm.totalQuestions)
        }
    }

    private var resultHeader: some View {
        HStack {
            Button(action: onDismiss) {
                Image(systemName: "xmark").font(.title3).foregroundStyle(.white)
                    .frame(width: 40, height: 40)
            }
            Spacer()
            Text("結果を確認")
                .font(.headline).foregroundStyle(.white)
            Spacer()
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .overlay(alignment: .bottom) {
            Divider().overlay(Color.appBorder)
        }
    }

    private var scoreCircle: some View {
        let pct = vm.totalQuestions > 0 ? Double(vm.correctCount) / Double(vm.totalQuestions) : 0
        let radius = (circleSize - strokeWidth) / 2
        let circumference = radius * 2 * .pi
        let dashOffset = circumference * (1 - pct)

        return ZStack {
            Circle()
                .stroke(Color.appSurfaceSecondary, lineWidth: strokeWidth)
                .frame(width: circleSize, height: circleSize)

            Circle()
                .trim(from: 0, to: pct)
                .stroke(Color.appPrimary, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                .frame(width: circleSize, height: circleSize)
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 1.0), value: pct)

            VStack(spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(vm.correctCount)")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(.white)
                    Text("/\(vm.totalQuestions)")
                        .font(.system(size: 28))
                        .foregroundStyle(.appTextSecondary)
                }
                Text("スコア")
                    .font(.caption2)
                    .foregroundStyle(.appTextSecondary)
                    .tracking(2)
            }
        }
        .padding(.top, 24)
    }

    private var scoreMessage: some View {
        let msg = vm.scoreMessage()
        return VStack(spacing: 8) {
            Text(msg.title)
                .font(.largeTitle.bold())
                .foregroundStyle(.white)
            Text(msg.subtitle)
                .font(.subheadline)
                .foregroundStyle(.appTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 20)
    }

    private var progressCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("検定合格への進捗")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
                Spacer()
                Text("レベル \(UserProgress.shared.level): \(UserProgress.shared.masteryPercentage)%")
                    .font(.caption.bold())
                    .foregroundStyle(.appPrimary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.appBorder).frame(height: 8)
                    Capsule().fill(Color.appPrimary)
                        .frame(width: geo.size.width * CGFloat(UserProgress.shared.masteryPercentage) / 100, height: 8)
                }
            }
            .frame(height: 8)

            Text("マスターレベルまであと\(100 - UserProgress.shared.masteryPercentage)ポイント")
                .font(.caption)
                .foregroundStyle(.appPrimary)
        }
        .padding(16)
        .background(Color.appSurfaceSecondary, in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 20)
    }

    private var artworksSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("今回学んだ作品")
                .font(.headline.bold())
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
            Text("コレクションに追加されました")
                .font(.caption)
                .foregroundStyle(.appTextSecondary)
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(vm.answerRecords, id: \.question.id) { record in
                        artworkCard(record: record)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private func artworkCard(record: AnswerRecord) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: record.question.artwork.imageURL) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.appSurfaceSecondary
                }
                .frame(width: 140, height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Image(systemName: record.isCorrect ? "checkmark" : "xmark")
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .padding(6)
                    .background(record.isCorrect ? Color.appSuccess : Color.appError, in: Circle())
                    .padding(8)
            }

            Text(record.question.artwork.displayArtist)
                .font(.caption.weight(.medium))
                .foregroundStyle(.white)
                .lineLimit(1)
            Text(record.question.artwork.era.japaneseName)
                .font(.caption2)
                .foregroundStyle(.appTextSecondary)
        }
        .frame(width: 140)
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: onDismiss) {
                Text("ホームに戻る")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.appPrimary, in: Capsule())
            }

            Button(action: onDismiss) {
                Text("もう一度挑戦する")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .overlay(Capsule().stroke(Color.appBorder, lineWidth: 2))
            }
        }
        .padding(.horizontal, 20)
    }
}
