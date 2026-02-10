import GoogleMobileAds
import SwiftUI

private func debugLog(_ message: String) {
    #if DEBUG
    print(message)
    #endif
}

class AdManager: NSObject, GADFullScreenContentDelegate {
    static let shared = AdManager()

    // Google's official test ad unit IDs for development
    #if DEBUG
    static let bannerAdUnitID = "ca-app-pub-3940256099942544/2435281174"
    private let interstitialAdUnitID = "ca-app-pub-3940256099942544/4411468910"
    #else
    static let bannerAdUnitID = "ca-app-pub-5955012909417750/3441204790"
    private let interstitialAdUnitID = "ca-app-pub-5955012909417750/9815041453"
    #endif

    private var interstitialAd: GADInterstitialAd?
    private var isLoadingInterstitial = false
    private var interstitialRetryCount = 0
    private static let maxRetries = 3

    @AppStorage("workoutsSinceLastAd") var workoutsSinceLastAd: Int = 0

    static let workoutsPerInterstitial = 2

    private override init() {
        super.init()
        preloadInterstitial()
    }

    // MARK: - Interstitial Loading

    func preloadInterstitial() {
        guard !SubscriptionManager.shared.isPremium else { return }
        guard !isLoadingInterstitial else { return }
        isLoadingInterstitial = true

        debugLog("[AdManager] Loading interstitial ad...")
        GADInterstitialAd.load(
            withAdUnitID: interstitialAdUnitID,
            request: GADRequest()
        ) { [weak self] ad, error in
            self?.isLoadingInterstitial = false
            if let error = error {
                debugLog("[AdManager] Failed to load interstitial: \(error.localizedDescription)")
                if let retryCount = self?.interstitialRetryCount, retryCount < Self.maxRetries {
                    self?.interstitialRetryCount = retryCount + 1
                    let delay = pow(2.0, Double(retryCount + 1))
                    debugLog("[AdManager] Retrying interstitial load in \(delay)s (attempt \(retryCount + 1)/\(Self.maxRetries))")
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        self?.preloadInterstitial()
                    }
                } else {
                    debugLog("[AdManager] Max retries reached, will try again on next workout")
                    self?.interstitialRetryCount = 0
                }
                return
            }
            self?.interstitialAd = ad
            ad?.fullScreenContentDelegate = self
            self?.interstitialRetryCount = 0
            debugLog("[AdManager] Interstitial ad loaded successfully")
        }
    }

    // MARK: - Workout Completed Hook

    func onWorkoutCompleted() {
        guard !SubscriptionManager.shared.isPremium else { return }
        workoutsSinceLastAd += 1
        debugLog("[AdManager] Workout count: \(workoutsSinceLastAd)/\(Self.workoutsPerInterstitial)")

        if workoutsSinceLastAd >= Self.workoutsPerInterstitial {
            showInterstitial()
        }
    }

    func incrementWorkoutCount() {
        workoutsSinceLastAd += 1
        debugLog("[AdManager] Workout count (deferred): \(workoutsSinceLastAd)/\(Self.workoutsPerInterstitial)")
    }

    // MARK: - Interstitial Presentation

    private func showInterstitial() {
        guard let ad = interstitialAd else {
            debugLog("[AdManager] Interstitial not ready, preloading for next time")
            preloadInterstitial()
            return
        }

        guard let rootViewController = Self.topViewController() else {
            debugLog("[AdManager] Could not find root view controller — scenes: \(UIApplication.shared.connectedScenes.count), keyWindow: \(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first?.windows.first(where: { $0.isKeyWindow }) != nil)")
            return
        }

        debugLog("[AdManager] Presenting interstitial ad from \(type(of: rootViewController))")
        ad.present(fromRootViewController: rootViewController)

        workoutsSinceLastAd = 0
        interstitialAd = nil
        // Preload happens in adDidDismissFullScreenContent delegate
    }

    // MARK: - GADFullScreenContentDelegate

    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        debugLog("[AdManager] Interstitial recorded impression")
    }

    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        debugLog("[AdManager] Interstitial failed to present: \(error.localizedDescription)")
        interstitialAd = nil
        preloadInterstitial()
    }

    func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        debugLog("[AdManager] Interstitial will dismiss")
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        debugLog("[AdManager] Interstitial dismissed, preloading next")
        interstitialAd = nil
        preloadInterstitial()
    }

    // MARK: - Helper

    private static func topViewController(
        base: UIViewController? = nil
    ) -> UIViewController? {
        let base = base ?? UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?
            .windows
            .first(where: { $0.isKeyWindow })?
            .rootViewController

        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return topViewController(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
