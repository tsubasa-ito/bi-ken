import GoogleMobileAds
import UIKit

// MARK: - Ad Unit IDs (テスト用ID。本番リリース前に差し替える)

private enum AdUnitID {
    static let banner = "ca-app-pub-3940256099942544/2934735716"
    static let interstitial = "ca-app-pub-3940256099942544/4411468910"
}

// MARK: - AdFrequencyController

struct AdFrequencyController {
    let showEvery: Int
    private var count: Int = 0

    init(showEvery: Int = 3) {
        self.showEvery = showEvery
    }

    mutating func shouldShow() -> Bool {
        count += 1
        return count % showEvery == 0
    }

    mutating func reset() {
        count = 0
    }
}

// MARK: - AdService

@MainActor
final class AdService: NSObject {
    static let shared = AdService()

    private var frequencyController: AdFrequencyController
    private var interstitialAd: GADInterstitialAd?
    private var onDismissCallback: (() -> Void)?

    static let bannerAdUnitID = AdUnitID.banner

    private override init() {
        frequencyController = AdFrequencyController(showEvery: 3)
    }

    func preload() {
        Task {
            do {
                let ad = try await GADInterstitialAd.load(
                    withAdUnitID: AdUnitID.interstitial,
                    request: GADRequest()
                )
                interstitialAd = ad
                interstitialAd?.fullScreenContentDelegate = self
            } catch {
                interstitialAd = nil
            }
        }
    }

    func showInterstitialIfNeeded(onDismiss: @escaping () -> Void) {
        guard
            let ad = interstitialAd,
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let rootVC = windowScene.windows.first?.rootViewController
        else {
            onDismiss()
            return
        }

        guard frequencyController.shouldShow() else {
            onDismiss()
            return
        }

        onDismissCallback = onDismiss
        interstitialAd = nil
        ad.present(fromRootViewController: rootVC)
    }
}

// MARK: - GADFullScreenContentDelegate

extension AdService: GADFullScreenContentDelegate {
    nonisolated func adDidDismissFullScreenContent(_ ad: any GADFullScreenPresentingAd) {
        Task { @MainActor [weak self] in
            self?.preload()
            self?.onDismissCallback?()
            self?.onDismissCallback = nil
        }
    }

    nonisolated func ad(
        _ ad: any GADFullScreenPresentingAd,
        didFailToPresentFullScreenContentWithError error: Error
    ) {
        Task { @MainActor [weak self] in
            self?.onDismissCallback?()
            self?.onDismissCallback = nil
        }
    }
}
