import SwiftUI
import UserNotifications

struct NotificationSettingsView: View {
    @State private var authStatus: UNAuthorizationStatus = .notDetermined

    var body: some View {
        List {
            Section {
                statusCard
            }
            .listRowBackground(Color.clear)

            Section("通知の設定") {
                statusRow
            }
            .listRowBackground(Color.appCardBG)

            if authStatus == .denied {
                Section {
                    Button {
                        openSettings()
                    } label: {
                        HStack {
                            Label("設定アプリで許可する", systemImage: "gear")
                                .foregroundStyle(.appPrimary)
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundStyle(.appTextTertiary)
                        }
                    }
                }
                .listRowBackground(Color.appCardBG)
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("通知")
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadStatus() }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            Task { await loadStatus() }
        }
    }

    private var statusCard: some View {
        HStack(spacing: 14) {
            Image(systemName: authStatus == .authorized ? "bell.badge.fill" : "bell.slash.fill")
                .font(.system(size: 28))
                .foregroundStyle(authStatus == .authorized ? Color.orange : Color.appTextSecondary)
            VStack(alignment: .leading, spacing: 4) {
                Text(authStatus == .authorized ? "通知が有効です" : authStatus == .denied ? "通知が無効です" : "通知の許可が必要です")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.appText)
                Text(authStatus == .authorized
                    ? "通知を受け取れます"
                    : authStatus == .denied
                    ? "設定アプリから許可してください"
                    : "タップして通知を許可する")
                    .font(.system(size: 12))
                    .foregroundStyle(.appTextSecondary)
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private var statusRow: some View {
        switch authStatus {
        case .notDetermined:
            Button {
                Task { await requestAuthorization() }
            } label: {
                Label("通知を許可する", systemImage: "bell.fill")
                    .foregroundStyle(.appPrimary)
            }
        case .authorized, .provisional:
            Label("通知: 許可済み", systemImage: "checkmark.circle.fill")
                .foregroundStyle(.appCorrect)
        case .denied:
            Label("通知: 拒否済み", systemImage: "xmark.circle.fill")
                .foregroundStyle(.appIncorrect)
        @unknown default:
            EmptyView()
        }
    }

    private func loadStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        authStatus = settings.authorizationStatus
    }

    private func requestAuthorization() async {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            authStatus = granted ? .authorized : .denied
        } catch {
            await loadStatus()
        }
    }

    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
