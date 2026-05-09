import SwiftUI
import UserNotifications

private let reminderEnabledKey = "reminderEnabled"
private let reminderTimeKey = "reminderTime"
private let reminderNotificationID = "daily-study-reminder"

struct ReminderSettingsView: View {
    @State private var isEnabled: Bool = false
    @State private var reminderTime: Date = defaultReminderTime()
    @State private var authStatus: UNAuthorizationStatus = .notDetermined

    var body: some View {
        List {
            Section {
                Toggle(isOn: $isEnabled) {
                    Label("毎日リマインダー", systemImage: "bell.fill")
                        .foregroundStyle(.appText)
                }
                .tint(.appPrimary)
                .onChange(of: isEnabled) { _, enabled in
                    Task { await applyChange(enabled: enabled) }
                }

                if isEnabled {
                    DatePicker(
                        "通知時刻",
                        selection: $reminderTime,
                        displayedComponents: .hourAndMinute
                    )
                    .foregroundStyle(.appText)
                    .onChange(of: reminderTime) { _, _ in
                        Task {
                            do { try await scheduleReminder() } catch { isEnabled = false }
                        }
                    }
                }
            }
            .listRowBackground(Color.appCardBG)

            if authStatus == .denied {
                Section {
                    Button {
                        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                        UIApplication.shared.open(url)
                    } label: {
                        HStack {
                            Label("設定アプリで通知を許可する", systemImage: "gear")
                                .foregroundStyle(.appPrimary)
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundStyle(.appTextTertiary)
                        }
                    }
                }
                .listRowBackground(Color.appCardBG)
            }

            Section {
                Text("設定した時刻に毎日プッシュ通知が届きます。通知を受け取るには、通知の許可が必要です。")
                    .font(.footnote)
                    .foregroundStyle(.appTextSecondary)
            }
            .listRowBackground(Color.clear)
        }
        .scrollContentBackground(.hidden)
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("学習リマインダー")
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadState() }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            Task { await loadState() }
        }
    }

    private func loadState() async {
        let ud = UserDefaults.standard
        isEnabled = ud.bool(forKey: reminderEnabledKey)
        if let saved = ud.object(forKey: reminderTimeKey) as? Date {
            reminderTime = saved
        }
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        authStatus = settings.authorizationStatus
        if authStatus == .denied { isEnabled = false }
    }

    private func applyChange(enabled: Bool) async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        authStatus = settings.authorizationStatus

        if enabled {
            if authStatus == .notDetermined {
                let granted: Bool
                do {
                    granted = try await UNUserNotificationCenter.current()
                        .requestAuthorization(options: [.alert, .sound, .badge])
                } catch {
                    isEnabled = false
                    return
                }
                authStatus = granted ? .authorized : .denied
                if !granted {
                    isEnabled = false
                    return
                }
            } else if authStatus == .denied {
                isEnabled = false
                return
            }
            do {
                try await scheduleReminder()
            } catch {
                isEnabled = false
                return
            }
        } else {
            UNUserNotificationCenter.current().removePendingNotificationRequests(
                withIdentifiers: [reminderNotificationID]
            )
        }
        UserDefaults.standard.set(enabled, forKey: reminderEnabledKey)
    }

    private func scheduleReminder() async throws {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [reminderNotificationID]
        )

        let content = UNMutableNotificationContent()
        content.title = "美術検定"
        content.body = "今日の学習タイムです！美術の知識を磨きましょう。"
        content.sound = .default

        let comps = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        let request = UNNotificationRequest(
            identifier: reminderNotificationID,
            content: content,
            trigger: trigger
        )
        try await UNUserNotificationCenter.current().add(request)
        UserDefaults.standard.set(reminderTime, forKey: reminderTimeKey)
    }
}

private func defaultReminderTime() -> Date {
    var comps = DateComponents()
    comps.hour = 20
    comps.minute = 0
    return Calendar.current.date(from: comps) ?? Date()
}
