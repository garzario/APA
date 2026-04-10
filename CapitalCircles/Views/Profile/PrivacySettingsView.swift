import SwiftUI

// MARK: - Privacy Settings

struct PrivacySettingsView: View {
    @AppStorage("privacy.biometricLock") private var biometricLock = true
    @AppStorage("privacy.shareAnalytics") private var shareAnalytics = false
    @AppStorage("privacy.locationAware") private var locationAware = false
    @AppStorage("privacy.smartSuggestions") private var smartSuggestions = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CCTheme.space7) {
                header

                privacyPrinciple

                toggleGroup(title: "Security") {
                    toggleRow(title: "Biometric lock", isOn: $biometricLock)
                }

                toggleGroup(title: "Data sharing") {
                    toggleRow(title: "Share anonymous analytics", isOn: $shareAnalytics)
                    Divider().padding(.leading, CCTheme.space5)
                    toggleRow(title: "Location-aware suggestions", isOn: $locationAware)
                    Divider().padding(.leading, CCTheme.space5)
                    toggleRow(title: "Smart card suggestions", isOn: $smartSuggestions)
                }

                CCSection("Your data") {
                    VStack(spacing: 0) {
                        Divider()
                        actionRow(title: "Download my data", color: CCTheme.ink) {}
                        Divider().padding(.leading, CCTheme.space5)
                        actionRow(title: "Delete account", color: CCTheme.red) {}
                        Divider()
                    }
                }
            }
            .padding(.vertical, CCTheme.space5)
            .padding(.bottom, CCTheme.space8)
        }
        .background(CCTheme.canvas)
        .navigationTitle("Privacy")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: CCTheme.space2) {
            Text("SETTINGS")
                .font(.ccCaption)
                .foregroundStyle(CCTheme.slate)
                .tracking(0.5)
            Text("Privacy & sharing")
                .font(.ccLargeTitle)
                .foregroundStyle(CCTheme.ink)
        }
        .padding(.horizontal, CCTheme.space5)
    }

    private var privacyPrinciple: some View {
        HStack(alignment: .top, spacing: CCTheme.space3) {
            Image(systemName: "lock.shield")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(CCTheme.navy)
            Text("You control what is shared and with whom. Your financial details stay private until you opt in.")
                .font(.ccFootnote)
                .foregroundStyle(CCTheme.slate)
                .lineSpacing(3)
        }
        .padding(CCTheme.space5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CCTheme.fog)
        .clipShape(RoundedRectangle(cornerRadius: CCTheme.radiusMedium))
        .padding(.horizontal, CCTheme.space5)
    }

    private func toggleGroup<Content: View>(title: String, @ViewBuilder content: @escaping () -> Content) -> some View {
        CCSection(title) {
            VStack(spacing: 0) {
                Divider()
                content()
                Divider()
            }
        }
    }

    private func toggleRow(title: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            Text(title)
                .font(.ccBody)
                .foregroundStyle(CCTheme.ink)
        }
        .tint(CCTheme.navy)
        .padding(.horizontal, CCTheme.space5)
        .padding(.vertical, CCTheme.space4)
    }

    private func actionRow(title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.ccBody)
                    .foregroundStyle(color)
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
}

// MARK: - Notification Settings

struct NotificationSettingsView: View {
    @AppStorage("notif.goalMilestones") private var goalMilestones = true
    @AppStorage("notif.circleUpdates") private var circleUpdates = true
    @AppStorage("notif.weeklyInsights") private var weeklyInsights = true
    @AppStorage("notif.cardSuggestions") private var cardSuggestions = true
    @AppStorage("notif.lowBalance") private var lowBalance = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CCTheme.space7) {
                header

                group(title: "Goals") {
                    row(title: "Milestone celebrations", isOn: $goalMilestones)
                    Divider().padding(.leading, CCTheme.space5)
                    row(title: "Deadline reminders", isOn: .constant(true))
                }

                group(title: "Circles") {
                    row(title: "New member activity", isOn: $circleUpdates)
                    Divider().padding(.leading, CCTheme.space5)
                    row(title: "Contributions from circle members", isOn: .constant(true))
                }

                group(title: "Insights") {
                    row(title: "Weekly Smart Statement", isOn: $weeklyInsights)
                    Divider().padding(.leading, CCTheme.space5)
                    row(title: "Card optimization tips", isOn: $cardSuggestions)
                }

                group(title: "Account") {
                    row(title: "Low balance alerts", isOn: $lowBalance)
                    Divider().padding(.leading, CCTheme.space5)
                    row(title: "Security alerts", isOn: .constant(true))
                }
            }
            .padding(.vertical, CCTheme.space5)
            .padding(.bottom, CCTheme.space8)
        }
        .background(CCTheme.canvas)
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: CCTheme.space2) {
            Text("SETTINGS")
                .font(.ccCaption)
                .foregroundStyle(CCTheme.slate)
                .tracking(0.5)
            Text("Notifications")
                .font(.ccLargeTitle)
                .foregroundStyle(CCTheme.ink)
        }
        .padding(.horizontal, CCTheme.space5)
    }

    private func group<Content: View>(title: String, @ViewBuilder content: @escaping () -> Content) -> some View {
        CCSection(title) {
            VStack(spacing: 0) {
                Divider()
                content()
                Divider()
            }
        }
    }

    private func row(title: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            Text(title)
                .font(.ccBody)
                .foregroundStyle(CCTheme.ink)
        }
        .tint(CCTheme.navy)
        .padding(.horizontal, CCTheme.space5)
        .padding(.vertical, CCTheme.space4)
    }
}

// MARK: - Accessibility Settings

struct AccessibilitySettingsView: View {
    @AppStorage("a11y.increaseContrast") private var increaseContrast = false
    @AppStorage("a11y.reduceMotion") private var reduceMotion = false
    @AppStorage("a11y.largeAmounts") private var largeAmounts = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CCTheme.space7) {
                VStack(alignment: .leading, spacing: CCTheme.space2) {
                    Text("SETTINGS")
                        .font(.ccCaption)
                        .foregroundStyle(CCTheme.slate)
                        .tracking(0.5)
                    Text("Accessibility")
                        .font(.ccLargeTitle)
                        .foregroundStyle(CCTheme.ink)
                }
                .padding(.horizontal, CCTheme.space5)

                CCSection("Display") {
                    VStack(spacing: 0) {
                        Divider()
                        toggleRow("Increase contrast", isOn: $increaseContrast)
                        Divider().padding(.leading, CCTheme.space5)
                        toggleRow("Reduce motion", isOn: $reduceMotion)
                        Divider().padding(.leading, CCTheme.space5)
                        toggleRow("Larger amount text", isOn: $largeAmounts)
                        Divider()
                    }
                }

                HStack(alignment: .top, spacing: CCTheme.space3) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(CCTheme.slate)
                    Text("Capital Circles supports VoiceOver, Dynamic Type, and high contrast system-wide.")
                        .font(.ccFootnote)
                        .foregroundStyle(CCTheme.slate)
                }
                .padding(.horizontal, CCTheme.space5)
            }
            .padding(.vertical, CCTheme.space5)
            .padding(.bottom, CCTheme.space8)
        }
        .background(CCTheme.canvas)
        .navigationTitle("Accessibility")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func toggleRow(_ title: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            Text(title)
                .font(.ccBody)
                .foregroundStyle(CCTheme.ink)
        }
        .tint(CCTheme.navy)
        .padding(.horizontal, CCTheme.space5)
        .padding(.vertical, CCTheme.space4)
    }
}

// MARK: - Edit Profile

struct EditProfileView: View {
    @Environment(AppStateManager.self) private var state
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var email: String = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: CCTheme.space7) {
                    VStack(alignment: .leading, spacing: CCTheme.space2) {
                        Text("EDIT PROFILE")
                            .font(.ccCaption)
                            .foregroundStyle(CCTheme.slate)
                            .tracking(0.5)
                        Text("Your details")
                            .font(.ccLargeTitle)
                            .foregroundStyle(CCTheme.ink)
                    }
                    .padding(.horizontal, CCTheme.space5)

                    VStack(alignment: .leading, spacing: CCTheme.space2) {
                        Text("NAME")
                            .font(.ccCaption)
                            .foregroundStyle(CCTheme.slate)
                            .tracking(0.5)
                        TextField("Your name", text: $name)
                            .font(.ccBody)
                            .padding(CCTheme.space4)
                            .background(CCTheme.fog)
                            .clipShape(RoundedRectangle(cornerRadius: CCTheme.radiusMedium))
                    }
                    .padding(.horizontal, CCTheme.space5)

                    VStack(alignment: .leading, spacing: CCTheme.space2) {
                        Text("EMAIL")
                            .font(.ccCaption)
                            .foregroundStyle(CCTheme.slate)
                            .tracking(0.5)
                        TextField("your@email.com", text: $email)
                            .font(.ccBody)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .padding(CCTheme.space4)
                            .background(CCTheme.fog)
                            .clipShape(RoundedRectangle(cornerRadius: CCTheme.radiusMedium))
                    }
                    .padding(.horizontal, CCTheme.space5)
                }
                .padding(.vertical, CCTheme.space5)
                .padding(.bottom, CCTheme.space9)
            }
            .background(CCTheme.canvas)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .font(.ccBody)
                        .foregroundStyle(CCTheme.ink)
                }
            }
            .overlay(alignment: .bottom) {
                VStack(spacing: 0) {
                    LinearGradient(
                        colors: [CCTheme.canvas.opacity(0), CCTheme.canvas],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 20)

                    Button {
                        state.currentUser.name = name
                        state.currentUser.email = email
                        dismiss()
                    } label: {
                        Text("Save changes")
                    }
                    .buttonStyle(CCPrimaryButtonStyle())
                    .padding(.horizontal, CCTheme.space5)
                    .padding(.bottom, CCTheme.space5)
                    .background(CCTheme.canvas)
                }
            }
            .onAppear {
                name = state.currentUser.name
                email = state.currentUser.email
            }
        }
    }
}

// MARK: - Card Detail

struct CardDetailView: View {
    let card: Card

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CCTheme.space7) {
                header
                visualCard
                detailsSection
                rewardsSection
            }
            .padding(.vertical, CCTheme.space5)
            .padding(.bottom, CCTheme.space8)
        }
        .background(CCTheme.canvas)
        .navigationTitle(card.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: CCTheme.space2) {
            Text("CAPITAL ONE")
                .font(.ccCaption)
                .foregroundStyle(CCTheme.slate)
                .tracking(0.5)
            Text(card.name)
                .font(.ccLargeTitle)
                .foregroundStyle(CCTheme.ink)
            Text(card.cardType.rewardsDescription)
                .font(.ccSubhead)
                .foregroundStyle(CCTheme.slate)
        }
        .padding(.horizontal, CCTheme.space5)
    }

    private var visualCard: some View {
        VStack(alignment: .leading, spacing: CCTheme.space6) {
            HStack {
                Text("CAPITAL ONE")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1)
                Spacer()
                Image(systemName: "wave.3.right")
                    .font(.system(size: 14))
            }

            Spacer()

            VStack(alignment: .leading, spacing: CCTheme.space3) {
                Text("•••• •••• •••• \(card.lastFourDigits)")
                    .font(.system(size: 16, weight: .medium, design: .monospaced))
                Text(card.name.uppercased())
                    .font(.system(size: 14, weight: .semibold))
                    .tracking(0.5)
            }
        }
        .foregroundStyle(.white)
        .padding(CCTheme.space5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 200)
        .background(CCTheme.navy)
        .clipShape(RoundedRectangle(cornerRadius: CCTheme.radiusLarge))
        .padding(.horizontal, CCTheme.space5)
    }

    private var detailsSection: some View {
        CCSection("Balance") {
            VStack(spacing: 0) {
                Divider()
                row(label: "Current balance", value: "$\(Int(card.currentBalance).formatted())")
                Divider().padding(.leading, CCTheme.space5)
                row(label: "Credit limit", value: "$\(Int(card.creditLimit).formatted())")
                Divider().padding(.leading, CCTheme.space5)
                row(label: "Available", value: "$\(Int(card.creditLimit - card.currentBalance).formatted())")
                Divider().padding(.leading, CCTheme.space5)
                row(label: "Rewards", value: "\(Int(card.rewardsBalance).formatted())")
                Divider()
            }
        }
    }

    private var rewardsSection: some View {
        CCSection("Rewards structure") {
            VStack(spacing: 0) {
                Divider()
                ForEach(Array(SpendingCategory.allCases.enumerated()), id: \.element) { index, category in
                    HStack {
                        Text(category.rawValue)
                            .font(.ccBody)
                            .foregroundStyle(CCTheme.ink)
                        Spacer()
                        Text("\(String(format: "%.1f", card.cardType.rewardRate(for: category)))x")
                            .font(.ccBody)
                            .foregroundStyle(CCTheme.slate)
                            .monospacedDigit()
                    }
                    .padding(.horizontal, CCTheme.space5)
                    .padding(.vertical, CCTheme.space4)
                    if index < SpendingCategory.allCases.count - 1 {
                        Divider().padding(.leading, CCTheme.space5)
                    }
                }
                Divider()
            }
        }
    }

    private func row(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.ccBody)
                .foregroundStyle(CCTheme.slate)
            Spacer()
            Text(value)
                .font(.ccBody)
                .foregroundStyle(CCTheme.ink)
                .monospacedDigit()
        }
        .padding(.horizontal, CCTheme.space5)
        .padding(.vertical, CCTheme.space4)
    }
}

// MARK: - Help

struct HelpView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CCTheme.space7) {
                VStack(alignment: .leading, spacing: CCTheme.space2) {
                    Text("SUPPORT")
                        .font(.ccCaption)
                        .foregroundStyle(CCTheme.slate)
                        .tracking(0.5)
                    Text("Help & support")
                        .font(.ccLargeTitle)
                        .foregroundStyle(CCTheme.ink)
                }
                .padding(.horizontal, CCTheme.space5)

                CCSection("Common questions") {
                    VStack(spacing: 0) {
                        Divider()
                        faq(title: "How do circles work?", body: "Circles are trusted groups where you track shared goals without combining finances.")
                        Divider()
                        faq(title: "Can others see my spending?", body: "No. Your personal spending stays private by default.")
                        Divider()
                        faq(title: "What is a Smart Statement?", body: "An AI-generated monthly summary of your spending with personalized insights.")
                        Divider()
                        faq(title: "How does the card optimizer work?", body: "It analyzes the spending category and recommends which of your Capital One cards earns the best rewards.")
                        Divider()
                    }
                }

                CCSection("Contact") {
                    VStack(spacing: 0) {
                        Divider()
                        contactRow(label: "Email", value: "support@capitalcircles.com")
                        Divider().padding(.leading, CCTheme.space5)
                        contactRow(label: "Phone", value: "1-800-CAP-ONE")
                        Divider()
                    }
                }
            }
            .padding(.vertical, CCTheme.space5)
            .padding(.bottom, CCTheme.space8)
        }
        .background(CCTheme.canvas)
        .navigationTitle("Help")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func faq(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.ccBody)
                .foregroundStyle(CCTheme.ink)
            Text(body)
                .font(.ccFootnote)
                .foregroundStyle(CCTheme.slate)
                .lineSpacing(2)
        }
        .padding(.horizontal, CCTheme.space5)
        .padding(.vertical, CCTheme.space4)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func contactRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.ccBody)
                .foregroundStyle(CCTheme.slate)
            Spacer()
            Text(value)
                .font(.ccBody)
                .foregroundStyle(CCTheme.ink)
        }
        .padding(.horizontal, CCTheme.space5)
        .padding(.vertical, CCTheme.space4)
    }
}

// MARK: - Policy

struct PolicyView: View {
    let title: String
    let content: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CCTheme.space5) {
                VStack(alignment: .leading, spacing: CCTheme.space2) {
                    Text("LEGAL")
                        .font(.ccCaption)
                        .foregroundStyle(CCTheme.slate)
                        .tracking(0.5)
                    Text(title)
                        .font(.ccLargeTitle)
                        .foregroundStyle(CCTheme.ink)
                }

                Text(content)
                    .font(.ccBody)
                    .foregroundStyle(CCTheme.ink)
                    .lineSpacing(6)
            }
            .padding(CCTheme.space5)
            .padding(.bottom, CCTheme.space8)
        }
        .background(CCTheme.canvas)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
