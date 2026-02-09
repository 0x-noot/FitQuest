import SwiftUI
import SwiftData
import UserNotifications
import UIKit
import GoogleMobileAds

@main
struct FitogatchiApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var modelContainerError: Error?

    var sharedModelContainer: ModelContainer? = {
        let schema = Schema([
            Player.self,
            Workout.self,
            WorkoutTemplate.self,
            Pet.self,
            DailyQuest.self,
            AuthState.self,
            Club.self,
            ClubActivity.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            print("❌ Failed to create ModelContainer: \(error)")
            print("❌ Error details: \(error.localizedDescription)")
            return nil
        }
    }()

    var body: some Scene {
        WindowGroup {
            if let container = sharedModelContainer {
                ContentView()
                    .preferredColorScheme(.dark)
                    .modelContainer(container)
            } else {
                DatabaseErrorView()
                    .preferredColorScheme(.dark)
            }
        }
    }
}

// MARK: - Database Error View

struct DatabaseErrorView: View {
    var body: some View {
        VStack(spacing: PixelScale.px(4)) {
            PixelIconView(icon: .star, size: 48, color: Color(hex: "FF5555"))

            PixelText("OOPS!", size: .xlarge)

            PixelText("UNABLE TO LOAD DATA", size: .medium, color: PixelTheme.textSecondary)

            VStack(spacing: PixelScale.px(2)) {
                PixelText("TRY THESE STEPS:", size: .small, color: PixelTheme.textSecondary)
                PixelText("1. CLOSE THE APP", size: .small, color: PixelTheme.textSecondary)
                PixelText("2. RESTART YOUR DEVICE", size: .small, color: PixelTheme.textSecondary)
                PixelText("3. REOPEN FITQUEST", size: .small, color: PixelTheme.textSecondary)
            }
            .padding(PixelScale.px(3))
            .background(PixelTheme.cardBackground)
            .pixelOutline()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(PixelTheme.background)
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Set up notification delegate
        UNUserNotificationCenter.current().delegate = NotificationManager.shared

        // Initialize Google Mobile Ads SDK
        GADMobileAds.sharedInstance().start(completionHandler: nil)

        return true
    }
}
