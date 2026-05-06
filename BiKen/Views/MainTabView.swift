import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("ホーム", systemImage: "house.fill") }

            CollectionView()
                .tabItem { Label("コレクション", systemImage: "photo.stack.fill") }

            ProgressView_()
                .tabItem { Label("進捗", systemImage: "chart.bar.fill") }

            SettingsView()
                .tabItem { Label("設定", systemImage: "gearshape.fill") }
        }
        .tint(.appPrimary)
    }
}
