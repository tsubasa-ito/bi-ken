import SwiftUI
import GoogleMobileAds

@main
struct BiKenApp: App {
    init() {
        URLCache.shared.memoryCapacity = 50 * 1024 * 1024
        URLCache.shared.diskCapacity  = 200 * 1024 * 1024
        MobileAds.shared.start { _ in
            Task { @MainActor in
                AdService.shared.preload()
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
    }
}

@MainActor
private struct AppRootView: View {
    @State private var appStoreURL: URL?

    var body: some View {
        HomeView()
            .preferredColorScheme(.light)
            .task { await checkForUpdate() }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                Task { await checkForUpdate() }
            }
            .alert("アップデートのお知らせ", isPresented: Binding(
                get: { appStoreURL != nil },
                set: { if !$0 { appStoreURL = nil } }
            )) {
                Button("アップデートする") {
                    if let url = appStoreURL {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                    appStoreURL = nil
                }
                Button("後で", role: .cancel) { appStoreURL = nil }
            } message: {
                Text("新しいバージョンが利用可能です。\nApp Storeでアップデートしてください。")
            }
    }

    private func checkForUpdate() async {
        if let url = await AppUpdateService.shared.checkForUpdate() {
            appStoreURL = url
        }
    }
}
