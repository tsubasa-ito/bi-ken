import SwiftUI

struct GoalSettingsView: View {
    private let progress = UserProgress.shared
    @State private var draftGoal: Int = 10

    private let goalOptions = [5, 10, 15, 20, 30]

    var body: some View {
        List {
            Section {
                goalPreview
            }
            .listRowBackground(Color.clear)

            Section("1日の目標問題数") {
                ForEach(goalOptions, id: \.self) { option in
                    Button {
                        draftGoal = option
                        progress.updateDailyGoal(option)
                    } label: {
                        HStack {
                            Text("\(option)問")
                                .foregroundStyle(.appText)
                            if option == 10 {
                                Text("おすすめ")
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.appAccent.opacity(0.3))
                                    .clipShape(Capsule())
                                    .foregroundStyle(.appText)
                            }
                            Spacer()
                            if draftGoal == option {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.appPrimary)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }
            }
            .listRowBackground(Color.appCardBG)

            Section {
                Text("目標を達成した日はホーム画面に達成バッジが表示されます。")
                    .font(.footnote)
                    .foregroundStyle(.appTextSecondary)
            }
            .listRowBackground(Color.clear)
        }
        .scrollContentBackground(.hidden)
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("目標設定")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { draftGoal = progress.dailyGoal }
    }

    private var goalPreview: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.appPrimary.opacity(0.12))
                    .frame(width: 56, height: 56)
                Image(systemName: "target")
                    .font(.system(size: 24))
                    .foregroundStyle(.appPrimary)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("現在の目標")
                    .font(.system(size: 12))
                    .foregroundStyle(.appTextSecondary)
                Text("1日 \(draftGoal)問")
                    .font(.system(size: 22, weight: .bold, design: .serif))
                    .foregroundStyle(.appText)
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
}
