import SwiftUI

@main
struct CapitalCirclesApp: App {
    @State private var appState = AppState()
    @State private var stateManager = AppStateManager.shared

    var body: some Scene {
        WindowGroup {
            Group {
                // Show onboarding if the user hasn't completed it yet OR if the
                // current user is empty (fresh install with stale UserDefaults).
                if appState.hasCompletedOnboarding && !stateManager.currentUser.name.isEmpty {
                    ContentView()
                } else {
                    OnboardingView()
                }
            }
            .environment(appState)
            .environment(stateManager)
            .tint(CCTheme.navy)
        }
    }
}

// MARK: - App State

/// Central app state that manages onboarding status and current user session.
/// In production, this would integrate with OAuth 2.0 and Capital One's
/// authentication service for secure session management.
@Observable
final class AppState {
    /// Stored property so @Observable tracks changes and triggers UI updates.
    /// Persisted to UserDefaults on every write through didSet.
    var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        }
    }

    var currentUserId: UUID? {
        didSet {
            UserDefaults.standard.set(currentUserId?.uuidString, forKey: "currentUserId")
        }
    }

    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        if let str = UserDefaults.standard.string(forKey: "currentUserId") {
            self.currentUserId = UUID(uuidString: str)
        } else {
            self.currentUserId = nil
        }
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
