import SwiftUI
import GoogleMobileAds

@main
struct BiKenApp: App {
    init() {
        URLCache.shared.memoryCapacity = 50 * 1024 * 1024
        URLCache.shared.diskCapacity  = 200 * 1024 * 1024
        GADMobileAds.sharedInstance().start { _ in
            Task { @MainActor in
                AdService.shared.preload()
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .preferredColorScheme(.light)
        }
    }
}
