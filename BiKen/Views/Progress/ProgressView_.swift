import SwiftUI

// Renamed to ProgressView_ to avoid conflict with SwiftUI's ProgressView
struct ProgressView_: View {
    private let progress = UserProgress.shared

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        levelCard
                        statsGrid
                        eraProgressSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("進捗")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private var levelCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("レベル \(progress.level)")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                    Text(progress.levelTitle)
                        .font(.subheadline)
                        .foregroundStyle(.appPrimary)
                }
                Spacer()
                ZStack {
                    Circle().fill(Color.appPrimary.opacity(0.2)).frame(width: 60, height: 60)
                    Text("\(progress.level)")
                        .font(.title.bold())
                        .foregroundStyle(.appPrimary)
                }
            }

            VStack(spacing: 6) {
                HStack {
                    Text("検定合格まで")
                        .font(.caption)
                        .foregroundStyle(.appTextSecondary)
                    Spacer()
                    Text("\(progress.masteryPercentage)%")
                        .font(.caption.bold())
                        .foregroundStyle(.appPrimary)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.appSurfaceSecondary).frame(height: 8)
                        Capsule().fill(Color.appPrimary)
                            .frame(width: geo.size.width * CGFloat(progress.masteryPercentage) / 100, height: 8)
                    }
                }
                .frame(height: 8)
            }
        }
        .padding(20)
        .background(Color.appSurface, in: RoundedRectangle(cornerRadius: 16))
    }

    private var statsGrid: some View {
        let items: [(String, String, String)] = [
            ("\(progress.currentStreak)", "日連続", "flame.fill"),
            ("\(progress.totalArtworksMet)", "鑑賞作品", "photo.fill"),
            ("\(progress.totalCertificates)", "認定証", "rosette"),
        ]
        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(items, id: \.0) { value, label, icon in
                VStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(.appPrimary)
                    Text(value)
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                    Text(label)
                        .font(.caption2)
                        .foregroundStyle(.appTextSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.appSurface, in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private var eraProgressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("時代別進捗")
                .font(.headline.bold())
                .foregroundStyle(.white)

            ForEach(Era.allCases, id: \.self) { era in
                eraProgressRow(era: era, percentage: Int.random(in: 20...80))
            }
        }
        .padding(20)
        .background(Color.appSurface, in: RoundedRectangle(cornerRadius: 16))
    }

    private func eraProgressRow(era: Era, percentage: Int) -> some View {
        VStack(spacing: 6) {
            HStack {
                Text(era.japaneseName)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white)
                Spacer()
                Text("\(percentage)%")
                    .font(.caption.bold())
                    .foregroundStyle(.appTextSecondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.appSurfaceSecondary).frame(height: 6)
                    Capsule().fill(Color(hex: era.gradientEnd))
                        .frame(width: geo.size.width * CGFloat(percentage) / 100, height: 6)
                }
            }
            .frame(height: 6)
        }
    }
}
