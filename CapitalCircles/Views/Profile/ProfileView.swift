import SwiftUI

struct ProfileView: View {
    @Environment(AppStateManager.self) private var state
    @Environment(AppState.self) private var appState
    @State private var showEditProfile = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CCTheme.space8) {
                header
                statsSection
                cardsSection
                settingsSection
                aboutSection
                signOutButton
            }
            .padding(.vertical, CCTheme.space5)
            .padding(.bottom, CCTheme.space9)
        }
        .background(CCTheme.canvas)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Text("Profile")
                    .font(.ccHeadline)
                    .foregroundStyle(CCTheme.ink)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showEditProfile = true
                } label: {
                    Text("Edit")
                        .font(.ccBody)
                        .foregroundStyle(CCTheme.ink)
                }
            }
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileView()
        }
    }

    private var header: some View {
        HStack(spacing: CCTheme.space4) {
            Image(systemName: state.currentUser.avatarIcon)
                .font(.system(size: 28, weight: .regular))
                .foregroundStyle(CCTheme.navy)
                .frame(width: 72, height: 72)
                .background(CCTheme.fog)
                .clipShape(SwiftUI.Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(state.currentUser.name)
                    .font(.ccTitle)
                    .foregroundStyle(CCTheme.ink)
                Text(state.currentUser.email)
                    .font(.ccFootnote)
                    .foregroundStyle(CCTheme.slate)
            }
            Spacer()
        }
        .padding(.horizontal, CCTheme.space5)
    }

    private var statsSection: some View {
        HStack(spacing: 0) {
            statBlock(value: "\(state.circles.count)", label: "Circles")
            Divider()
                .frame(height: 40)
            statBlock(value: "\(state.allGoals.count)", label: "Goals")
            Divider()
                .frame(height: 40)
            statBlock(value: "$\(shortAmount(state.totalSaved))", label: "Saved")
        }
        .padding(.vertical, CCTheme.space5)
        .frame(maxWidth: .infinity)
        .background(CCTheme.fog)
        .clipShape(RoundedRectangle(cornerRadius: CCTheme.radiusMedium))
        .padding(.horizontal, CCTheme.space5)
    }

    private func statBlock(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.ccHeadline)
                .foregroundStyle(CCTheme.ink)
                .monospacedDigit()
            Text(label.uppercased())
                .font(.ccCaption)
                .foregroundStyle(CCTheme.slate)
                .tracking(0.5)
        }
        .frame(maxWidth: .infinity)
    }

    private var cardsSection: some View {
        CCSection("Capital One cards") {
            VStack(spacing: 0) {
                Divider()
                ForEach(Array(state.currentUser.cards.enumerated()), id: \.element.id) { index, card in
                    NavigationLink(destination: CardDetailView(card: card)) {
                        cardRow(card)
                    }
                    .buttonStyle(.plain)
                    if index < state.currentUser.cards.count - 1 {
                        Divider().padding(.leading, CCTheme.space5)
                    }
                }
                Divider()
            }
        }
    }

    private func cardRow(_ card: Card) -> some View {
        HStack(spacing: CCTheme.space4) {
            Image(systemName: "creditcard")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(CCTheme.navy)
                .frame(width: 36, height: 36)
                .background(CCTheme.fog)
                .clipShape(SwiftUI.Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(card.name)
                    .font(.ccBody)
                    .foregroundStyle(CCTheme.ink)
                Text("•••• \(card.lastFourDigits)")
                    .font(.ccFootnote)
                    .foregroundStyle(CCTheme.slate)
                    .monospacedDigit()
            }

            Spacer()

            Text("$\(Int(card.currentBalance).formatted())")
                .font(.ccBody)
                .foregroundStyle(CCTheme.slate)
                .monospacedDigit()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(CCTheme.mist)
        }
        .padding(.horizontal, CCTheme.space5)
        .padding(.vertical, CCTheme.space4)
        .contentShape(Rectangle())
    }

    private var settingsSection: some View {
        CCSection("Settings") {
            VStack(spacing: 0) {
                Divider()
                settingsLink(icon: "lock.shield", title: "Privacy & sharing", destination: PrivacySettingsView())
                Divider().padding(.leading, CCTheme.space5)
                settingsLink(icon: "bell", title: "Notifications", destination: NotificationSettingsView())
                Divider().padding(.leading, CCTheme.space5)
                settingsLink(icon: "accessibility", title: "Accessibility", destination: AccessibilitySettingsView())
                Divider()
            }
        }
    }

    private var aboutSection: some View {
        CCSection("About") {
            VStack(spacing: 0) {
                Divider()
                settingsLink(icon: "questionmark.circle", title: "Help & support", destination: HelpView())
                Divider().padding(.leading, CCTheme.space5)
                settingsLink(icon: "doc.text", title: "Terms of service", destination: PolicyView(title: "Terms of Service", content: termsText))
                Divider().padding(.leading, CCTheme.space5)
                settingsLink(icon: "hand.raised", title: "Privacy policy", destination: PolicyView(title: "Privacy Policy", content: privacyText))
                Divider()
            }
        }
    }

    private func settingsLink<Destination: View>(icon: String, title: String, destination: Destination) -> some View {
        NavigationLink(destination: destination) {
            HStack(spacing: CCTheme.space4) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(CCTheme.ink)
                    .frame(width: 28, alignment: .center)
                Text(title)
                    .font(.ccBody)
                    .foregroundStyle(CCTheme.ink)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(CCTheme.mist)
            }
            .padding(.horizontal, CCTheme.space5)
            .padding(.vertical, CCTheme.space4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var signOutButton: some View {
        Button {
            appState.resetOnboarding()
        } label: {
            Text("Sign out")
                .font(.ccBody)
                .foregroundStyle(CCTheme.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, CCTheme.space4)
        }
        .padding(.horizontal, CCTheme.space5)
    }

    private func shortAmount(_ value: Double) -> String {
        if value >= 1000 {
            return String(format: "%.0fK", value / 1000)
        }
        return String(Int(value))
    }
}

// MARK: - Policy text

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
