import SwiftUI

struct ProfileView: View {
    @Environment(AppState.self) private var appState
    private let data = MockDataService.shared

    var body: some View {
        NavigationStack {
            List {
                // Profile header
                Section {
                    HStack(spacing: 16) {
                        Image(systemName: data.currentUser.avatarIcon)
                            .font(.system(size: 40))
                            .foregroundStyle(CCTheme.primaryBlue)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(data.currentUser.name)
                                .font(.title3.bold())
                            Text(data.currentUser.email)
                                .font(.caption)
                                .foregroundStyle(CCTheme.textSecondary)
                        }
                    }
                    .padding(.vertical, 8)
                }

                // Cards section
                Section("My Capital One Cards") {
                    ForEach(data.currentUser.cards) { card in
                        HStack {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(card.cardType.color)
                                .frame(width: 40, height: 26)
                                .overlay {
                                    Text("C1")
                                        .font(.caption2.bold())
                                        .foregroundStyle(.white)
                                }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(card.name)
                                    .font(.subheadline.bold())
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

                // Settings
                Section("Settings") {
                    // In production, these would connect to Capital One's
                    // account settings and notification preferences
                    Label("Privacy & Sharing", systemImage: "lock.shield.fill")
                    Label("Notifications", systemImage: "bell.fill")
                    Label("Card Preferences", systemImage: "creditcard.fill")
                    Label("Accessibility", systemImage: "accessibility")
                }

                // About
                Section("About") {
                    Label("Help & Support", systemImage: "questionmark.circle.fill")
                    Label("Terms of Service", systemImage: "doc.text.fill")
                    Label("Privacy Policy", systemImage: "hand.raised.fill")
                }

                Section {
                    Button(role: .destructive) {
                        appState.resetOnboarding()
                    } label: {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfileView()
        .environment(AppState())
}
