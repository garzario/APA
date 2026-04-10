import SwiftUI

@main
struct CapitalCirclesApp: App {
    @State private var appState = AppState()
    @State private var stateManager = AppStateManager.shared

    var body: some Scene {
        WindowGroup {
            Group {
                if appState.hasCompletedOnboarding {
                    ContentView()
                } else {
                    OnboardingView()
                }
            }
            .environment(appState)
            .environment(stateManager)
            .tint(CCTheme.primaryBlue)
        }
    }
}

// MARK: - App State

/// Central app state that manages onboarding status and current user session.
/// In production, this would integrate with OAuth 2.0 and Capital One's
/// authentication service for secure session management.
@Observable
final class AppState {
    var hasCompletedOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") }
        set { UserDefaults.standard.set(newValue, forKey: "hasCompletedOnboarding") }
    }

    var currentUserId: UUID? {
        get {
            guard let str = UserDefaults.standard.string(forKey: "currentUserId") else { return nil }
            return UUID(uuidString: str)
        }
        set { UserDefaults.standard.set(newValue?.uuidString, forKey: "currentUserId") }
    }

    func completeOnboarding(userId: UUID) {
        currentUserId = userId
        hasCompletedOnboarding = true
    }

    func resetOnboarding() {
        hasCompletedOnboarding = false
        currentUserId = nil
    }
}
