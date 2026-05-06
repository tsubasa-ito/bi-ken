import SwiftUI

struct HomeView: View {
    @State private var vm = HomeViewModel()
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                LinearGradient(colors: [Color(hex: "0D1117"), Color(hex: "161B22")],
                               startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        headerView
                        dailyChallengeSection
                        eraSection
                        progressSection
                    }
                    .padding(.bottom, 32)
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(for: String.self) { quizID in
                QuizView(eraID: quizID)
            }
            .navigationDestination(for: Artwork.self) { artwork in
                ArtworkDetailView(artwork: artwork)
            }
        }
        .task { await vm.load() }
    }

    // MARK: Header

    private var headerView: some View {
        HStack {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.appSurfaceSecondary)
                    .frame(width: 40, height: 40)
                    .overlay { Image(systemName: "person").foregroundStyle(.white) }

                VStack(alignment: .leading, spacing: 2) {
                    Text("美術検定")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                    Text("レベル \(UserProgress.shared.level)　\(UserProgress.shared.levelTitle)")
                        .font(.caption)
                        .foregroundStyle(.appPrimary)
                }
            }
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.title3)
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    // MARK: Daily Challenge

    private var dailyChallengeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今日の一問")
                .font(.title3.bold())
                .foregroundStyle(.white)
                .padding(.horizontal, 20)

            if vm.isLoading {
                loadingCard
            } else if let artwork = vm.dailyArtwork {
                dailyCard(artwork: artwork)
            } else {
                errorCard
            }
        }
    }

    private var loadingCard: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.appSurface)
            .frame(minHeight: 280)
            .overlay {
                VStack(spacing: 12) {
                    ProgressView().tint(.appPrimary)
                    Text("作品を読み込み中...").font(.caption).foregroundStyle(.appTextSecondary)
                }
            }
            .padding(.horizontal, 20)
    }

    private var errorCard: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.appSurface)
            .frame(minHeight: 180)
            .overlay {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.circle").font(.title).foregroundStyle(.appError)
                    Text("読み込みに失敗しました").font(.caption).foregroundStyle(.appTextSecondary)
                }
            }
            .padding(.horizontal, 20)
    }

    private func dailyCard(artwork: Artwork) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            AsyncImage(url: artwork.imageURL) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color.appSurfaceSecondary
            }
            .frame(height: 180)
            .clipped()

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(artwork.displayTitle)
                            .font(.headline.bold())
                            .foregroundStyle(.white)
                            .lineLimit(1)
                        Text("\(artwork.displayArtist)\(artwork.year.map { "、\($0)年" } ?? "")")
                            .font(.caption)
                            .foregroundStyle(.appPrimary)
                    }
                    Spacer()
                    Text("50 XP")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.appSurfaceSecondary, in: RoundedRectangle(cornerRadius: 6))
                }

                Text("この作品の作者を当ててみましょう。美術検定の基礎問題です。")
                    .font(.caption)
                    .foregroundStyle(.appTextSecondary)
                    .lineLimit(2)

                HStack {
                    HStack(spacing: -8) {
                        ForEach(0..<3, id: \.self) { i in
                            Circle()
                                .fill(Color.appPrimary)
                                .frame(width: 24, height: 24)
                                .overlay { Circle().strokeBorder(.white, lineWidth: 2) }
                        }
                    }
                    Text("本日 1.2千人が挑戦中")
                        .font(.caption2)
                        .foregroundStyle(.appTextSecondary)

                    Spacer()

                    Button {
                        navigationPath.append("daily")
                    } label: {
                        Text("挑戦する")
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.appPrimary, in: Capsule())
                    }
                }
            }
            .padding(16)
        }
        .background(Color.appSurface, in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 20)
    }

    // MARK: Era Section

    private var eraSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("時代から学ぶ")
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                Spacer()
                Text("すべて見る")
                    .font(.caption)
                    .foregroundStyle(.appPrimary)
            }
            .padding(.horizontal, 20)

            let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(Era.allCases, id: \.self) { era in
                    Button { navigationPath.append(era.quizID) } label: {
                        EraCardView(era: era)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: Progress Section

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("学習の記録")
                .font(.title3.bold())
                .foregroundStyle(.white)
                .padding(.horizontal, 20)

            VStack(spacing: 16) {
                HStack {
                    Text("検定合格に向けて")
                        .font(.caption)
                        .foregroundStyle(.appTextSecondary)
                    Spacer()
                    Text("\(UserProgress.shared.masteryPercentage)%")
                        .font(.caption.bold())
                        .foregroundStyle(.appPrimary)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.appSurfaceSecondary).frame(height: 8)
                        Capsule().fill(Color.appPrimary)
                            .frame(width: geo.size.width * CGFloat(UserProgress.shared.masteryPercentage) / 100, height: 8)
                    }
                }
                .frame(height: 8)

                HStack {
                    statItem(value: "\(UserProgress.shared.currentStreak)", label: "日連続")
                    Divider().frame(height: 32).overlay(Color.appBorder)
                    statItem(value: "\(UserProgress.shared.totalArtworksMet)", label: "作品")
                    Divider().frame(height: 32).overlay(Color.appBorder)
                    statItem(value: "\(UserProgress.shared.totalCertificates)", label: "認定証")
                }
            }
            .padding(16)
            .background(Color.appSurface, in: RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 20)
        }
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.title2.bold()).foregroundStyle(.white)
            Text(label).font(.caption2).foregroundStyle(.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct EraCardView: View {
    let era: Era

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [Color(hex: era.gradientStart), Color(hex: era.gradientEnd)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .frame(height: 140)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            VStack(alignment: .leading, spacing: 2) {
                Text(era.japaneseName)
                    .font(.headline.bold())
                    .foregroundStyle(.white)
                Text(era.period)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(12)
        }
    }
}
