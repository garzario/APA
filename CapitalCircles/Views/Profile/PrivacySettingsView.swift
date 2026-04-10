import SwiftUI

struct PrivacySettingsView: View {
    @AppStorage("privacy.biometricLock") private var biometricLock = true
    @AppStorage("privacy.shareAnalytics") private var shareAnalytics = false
    @AppStorage("privacy.locationAware") private var locationAware = false
    @AppStorage("privacy.smartSuggestions") private var smartSuggestions = true

    var body: some View {
        List {
            Section {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "lock.shield.fill")
                        .font(.title2)
                        .foregroundStyle(CCTheme.primaryBlue)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Privacy first by design")
                            .font(.subheadline.bold())
                        Text("You control what is shared and with whom. Your financial details stay private until you opt in.")
                            .font(.caption)
                            .foregroundStyle(CCTheme.textSecondary)
                    }
                }
                .padding(.vertical, 4)
            }

            Section("Security") {
                Toggle(isOn: $biometricLock) {
                    Label("Biometric lock", systemImage: "faceid")
                }
            }

            Section("Data sharing") {
                Toggle(isOn: $shareAnalytics) {
                    Label("Share anonymous analytics", systemImage: "chart.bar.fill")
                }
                Toggle(isOn: $locationAware) {
                    Label("Location-aware suggestions", systemImage: "location.fill")
                }
                Toggle(isOn: $smartSuggestions) {
                    Label("Smart card suggestions", systemImage: "sparkles")
                }
            }

            Section("Your data") {
                Button {} label: {
                    Label("Download my data", systemImage: "arrow.down.doc.fill")
                }
                Button(role: .destructive) {} label: {
                    Label("Delete account", systemImage: "trash.fill")
                }
            }
        }
        .navigationTitle("Privacy & Sharing")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct NotificationSettingsView: View {
    @AppStorage("notif.goalMilestones") private var goalMilestones = true
    @AppStorage("notif.circleUpdates") private var circleUpdates = true
    @AppStorage("notif.weeklyInsights") private var weeklyInsights = true
    @AppStorage("notif.cardSuggestions") private var cardSuggestions = true
    @AppStorage("notif.lowBalance") private var lowBalance = true

    var body: some View {
        List {
            Section("Goals") {
                Toggle("Milestone celebrations", isOn: $goalMilestones)
                Toggle("Deadline reminders", isOn: .constant(true))
            }

            Section("Circles") {
                Toggle("New member activity", isOn: $circleUpdates)
                Toggle("Contributions from circle members", isOn: .constant(true))
            }

            Section("Insights") {
                Toggle("Weekly Smart Statement", isOn: $weeklyInsights)
                Toggle("Card optimization tips", isOn: $cardSuggestions)
            }

            Section("Account") {
                Toggle("Low balance alerts", isOn: $lowBalance)
                Toggle("Security alerts", isOn: .constant(true))
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AccessibilitySettingsView: View {
    @AppStorage("a11y.increaseContrast") private var increaseContrast = false
    @AppStorage("a11y.reduceMotion") private var reduceMotion = false
    @AppStorage("a11y.largeAmounts") private var largeAmounts = false

    var body: some View {
        List {
            Section("Display") {
                Toggle("Increase contrast", isOn: $increaseContrast)
                Toggle("Reduce motion", isOn: $reduceMotion)
                Toggle("Larger amount text", isOn: $largeAmounts)
            }

            Section {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(CCTheme.accentBlue)
                    Text("Capital Circles supports VoiceOver, Dynamic Type, and high contrast system-wide. These settings complement iOS accessibility settings.")
                        .font(.caption)
                        .foregroundStyle(CCTheme.textSecondary)
                }
            }
        }
        .navigationTitle("Accessibility")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct EditProfileView: View {
    @Environment(AppStateManager.self) private var state
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var email: String = ""

    var body: some View {
        Form {
            Section("Personal info") {
                TextField("Name", text: $name)
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
            }
            Section("Avatar") {
                HStack(spacing: 12) {
                    Image(systemName: state.currentUser.avatarIcon)
                        .font(.title)
                        .foregroundStyle(CCTheme.primaryBlue)
                        .frame(width: 60, height: 60)
                        .background(CCTheme.lightBlue)
                        .clipShape(SwiftUI.Circle())
                    Text("Avatar editing will be available in a future update")
                        .font(.caption)
                        .foregroundStyle(CCTheme.textSecondary)
                }
            }
        }
        .navigationTitle("Edit profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    state.currentUser.name = name
                    state.currentUser.email = email
                    dismiss()
                }
                .bold()
            }
        }
        .onAppear {
            name = state.currentUser.name
            email = state.currentUser.email
        }
    }
}

struct CardDetailView: View {
    let card: Card

    var body: some View {
        ScrollView {
            VStack(spacing: CCTheme.paddingLarge) {
                CapitalOneCardView(card: card)
                    .frame(height: 200)
                    .padding(.horizontal)

                VStack(spacing: 0) {
                    detailRow("Current balance", "$\(Int(card.currentBalance).formatted())", icon: "creditcard.fill")
                    Divider().padding(.leading, 56)
                    detailRow("Credit limit", "$\(Int(card.creditLimit).formatted())", icon: "chart.bar.fill")
                    Divider().padding(.leading, 56)
                    detailRow("Available credit", "$\(Int(card.creditLimit - card.currentBalance).formatted())", icon: "checkmark.circle.fill")
                    Divider().padding(.leading, 56)
                    detailRow("Rewards balance", "\(Int(card.rewardsBalance).formatted())", icon: "star.fill")
                }
                .padding(.horizontal, CCTheme.paddingMedium)
                .background(CCTheme.backgroundCard)
                .clipShape(RoundedRectangle(cornerRadius: CCTheme.cornerRadiusMedium))
                .shadow(color: .black.opacity(0.04), radius: 8, y: 2)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Rewards structure")
                        .font(.headline)
                    ForEach(SpendingCategory.allCases, id: \.self) { category in
                        HStack {
                            Label(category.rawValue, systemImage: category.icon)
                                .font(.subheadline)
                            Spacer()
                            Text("\(String(format: "%.1f", card.cardType.rewardRate(for: category)))x")
                                .font(.subheadline.bold())
                                .foregroundStyle(CCTheme.primaryBlue)
                        }
                        .padding(.vertical, 6)
                        if category != SpendingCategory.allCases.last {
                            Divider()
                        }
                    }
                }
                .padding(CCTheme.paddingMedium)
                .background(CCTheme.backgroundCard)
                .clipShape(RoundedRectangle(cornerRadius: CCTheme.cornerRadiusMedium))
                .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
            }
            .padding(.horizontal, CCTheme.paddingMedium)
            .padding(.vertical, CCTheme.paddingMedium)
        }
        .background(CCTheme.backgroundPrimary)
        .navigationTitle(card.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func detailRow(_ label: String, _ value: String, icon: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .foregroundStyle(CCTheme.primaryBlue)
                .frame(width: 32, height: 32)
                .background(CCTheme.lightBlue)
                .clipShape(SwiftUI.Circle())
            Text(label)
                .font(.subheadline)
                .foregroundStyle(CCTheme.textSecondary)
            Spacer()
            Text(value)
                .font(.subheadline.bold())
                .foregroundStyle(CCTheme.textPrimary)
        }
        .padding(.vertical, 14)
    }
}

struct HelpView: View {
    var body: some View {
        List {
            Section("Common questions") {
                helpItem(title: "How do circles work?", body: "Circles are trusted groups where you track shared goals without combining finances.")
                helpItem(title: "Can others see my spending?", body: "No, your personal spending stays private by default. You can opt in to share categories or full details in circle settings.")
                helpItem(title: "What is a Smart Statement?", body: "An AI-generated monthly summary of your spending with personalized insights and tips.")
                helpItem(title: "How does the Card Optimizer work?", body: "It analyzes the spending category and recommends which of your Capital One cards earns the best rewards.")
            }

            Section("Contact") {
                Label("support@capitalcircles.com", systemImage: "envelope.fill")
                Label("1-800-CAP-ONE", systemImage: "phone.fill")
            }
        }
        .navigationTitle("Help & Support")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func helpItem(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline.bold())
            Text(body)
                .font(.caption)
                .foregroundStyle(CCTheme.textSecondary)
        }
        .padding(.vertical, 4)
    }
}

struct PolicyView: View {
    let title: String
    let content: String

    var body: some View {
        ScrollView {
            Text(content)
                .font(.subheadline)
                .foregroundStyle(CCTheme.textPrimary)
                .padding()
        }
        .background(CCTheme.backgroundPrimary)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
