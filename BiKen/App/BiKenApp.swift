import SwiftUI

@main
struct BiKenApp: App {
    init() {
        URLCache.shared.memoryCapacity = 50 * 1024 * 1024
        URLCache.shared.diskCapacity  = 200 * 1024 * 1024
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(.dark)
        }
    }
}
