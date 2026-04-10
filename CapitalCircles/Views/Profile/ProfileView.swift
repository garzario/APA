import SwiftUI

struct ProfileView: View {
    @Environment(AppStateManager.self) private var state
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationStack {
            List {
                // Profile header
                Section {
                    NavigationLink(destination: EditProfileView()) {
                        HStack(spacing: 16) {
                            Image(systemName: state.currentUser.avatarIcon)
                                .font(.system(size: 40))
                                .foregroundStyle(CCTheme.primaryBlue)
                                .frame(width: 60, height: 60)
                                .background(CCTheme.lightBlue)
                                .clipShape(SwiftUI.Circle())
                            VStack(alignment: .leading, spacing: 4) {
                                Text(state.currentUser.name)
                                    .font(.title3.bold())
                                    .foregroundStyle(CCTheme.textPrimary)
                                Text(state.currentUser.email)
                                    .font(.caption)
                                    .foregroundStyle(CCTheme.textSecondary)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }

                // Stats
                Section {
                    HStack(spacing: 14) {
                        statItem(label: "Circles", value: "\(state.circles.count)", icon: "person.3.fill")
                        Divider()
                        statItem(label: "Goals", value: "\(state.allGoals.count)", icon: "target")
                        Divider()
                        statItem(label: "Saved", value: "$\((Int(state.totalSaved) / 1000))k", icon: "dollarsign.circle.fill")
                    }
                    .padding(.vertical, 4)
                }

                // Cards
                Section("My Capital One cards") {
                    ForEach(state.currentUser.cards) { card in
                        NavigationLink(destination: CardDetailView(card: card)) {
                            HStack(spacing: 14) {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(card.cardType.color)
                                    .frame(width: 44, height: 30)
                                    .overlay {
                                        Text("C1")
                                            .font(.caption2.bold())
                                            .foregroundStyle(.white)
                                    }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(card.name)
                                        .font(.subheadline.bold())
                                        .foregroundStyle(CCTheme.textPrimary)
                                    Text("**** \(card.lastFourDigits)")
                                        .font(.caption)
                                        .foregroundStyle(CCTheme.textSecondary)
                                }
                                Spacer()
                                Text("$\(Int(card.currentBalance).formatted())")
                                    .font(.subheadline)
                                    .foregroundStyle(CCTheme.textSecondary)
                            }
                        }
                    }
                }

                // Settings
                Section("Settings") {
                    NavigationLink(destination: PrivacySettingsView()) {
                        Label("Privacy & Sharing", systemImage: "lock.shield.fill")
                    }
                    NavigationLink(destination: NotificationSettingsView()) {
                        Label("Notifications", systemImage: "bell.fill")
                    }
                    NavigationLink(destination: AccessibilitySettingsView()) {
                        Label("Accessibility", systemImage: "accessibility")
                    }
                }

                // About
                Section("About") {
                    NavigationLink(destination: HelpView()) {
                        Label("Help & Support", systemImage: "questionmark.circle.fill")
                    }
                    NavigationLink(destination: PolicyView(title: "Terms of Service", content: termsText)) {
                        Label("Terms of Service", systemImage: "doc.text.fill")
                    }
                    NavigationLink(destination: PolicyView(title: "Privacy Policy", content: privacyText)) {
                        Label("Privacy Policy", systemImage: "hand.raised.fill")
                    }
                }

                Section {
                    Button(role: .destructive) {
                        appState.resetOnboarding()
                    } label: {
                        Label("Sign out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }

    private func statItem(label: String, value: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(CCTheme.primaryBlue)
                .font(.subheadline)
            Text(value)
                .font(.headline)
                .foregroundStyle(CCTheme.textPrimary)
            Text(label)
                .font(.caption2)
                .foregroundStyle(CCTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

private let termsText = """
By using Capital Circles you agree to share your financial data with trusted circle members at your discretion. Capital Circles is a Capital One product and follows all applicable banking regulations. Your data is encrypted at rest and in transit.

You may leave any circle at any time, which will remove your contributions from shared views. Personal financial data is never shared without your explicit consent.

Capital One reserves the right to update these terms. Continued use of the app constitutes acceptance of any changes.
"""

private let privacyText = """
Capital Circles is privacy-first. Here is what we do and do not do:

We DO:
- Encrypt all financial data end to end
- Let you control what is visible to each member
- Store your preferences locally when possible
- Use AI only to generate insights from your own data

We DO NOT:
- Share your personal spending with any circle by default
- Sell your data to third parties
- Let juniors view parent financial details
- Combine financial accounts across members

You can export or delete your data at any time by contacting support.
"""
