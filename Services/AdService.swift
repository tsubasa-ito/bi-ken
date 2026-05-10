import GoogleMobileAds
import UIKit

// MARK: - Ad Unit IDs

private enum AdUnitID {
    #if DEBUG
    static let banner       = "ca-app-pub-3940256099942544/2934735716"
    static let interstitial = "ca-app-pub-3940256099942544/4411468910"
    #else
    static let banner       = "ca-app-pub-6267199278067658/9544317718"
    static let interstitial = "ca-app-pub-6267199278067658/5251895081"
    #endif
}

// MARK: - AdService

@MainActor
final class AdService: NSObject {
    static let shared = AdService()

    private var interstitialAd: InterstitialAd?
    private var onDismissCallback: (() -> Void)?

    static let bannerAdUnitID = AdUnitID.banner

    private override init() {}

    func preload() {
        Task {
            do {
                let ad = try await InterstitialAd.load(
                    with: AdUnitID.interstitial,
                    request: Request()
                )
                interstitialAd = ad
                interstitialAd?.fullScreenContentDelegate = self
            } catch {
                interstitialAd = nil
            }
        }
    }

    func showInterstitial(onDismiss: @escaping () -> Void) {
        guard
            let ad = interstitialAd,
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let rootVC = windowScene.windows.first?.rootViewController
        else {
            onDismiss()
            return
        }

        onDismissCallback = onDismiss
        interstitialAd = nil
        ad.present(from: rootVC)
    }
}

// MARK: - FullScreenContentDelegate

extension AdService: FullScreenContentDelegate {
    nonisolated func adDidDismissFullScreenContent(_ ad: any FullScreenPresentingAd) {
        Task { @MainActor [weak self] in
            self?.preload()
            self?.onDismissCallback?()
            self?.onDismissCallback = nil
        }
    }

    nonisolated func ad(
        _ ad: any FullScreenPresentingAd,
        didFailToPresentFullScreenContentWithError error: Error
    ) {
        Task { @MainActor [weak self] in
            self?.onDismissCallback?()
            self?.onDismissCallback = nil
        }
    }
}
