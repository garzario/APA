import SwiftUI

struct OnboardingView: View {
    @Environment(AppState.self) private var appState
    @State private var currentPage = 0

    private let pages: [(icon: String, title: String, description: String)] = [
        ("person.3.fill", "Better Together",
         "Create circles with family, friends, and roommates to support each other's financial goals."),
        ("lock.shield.fill", "Privacy First",
         "Your finances stay private. You choose what to share, with whom, and how much."),
        ("chart.bar.fill", "Smart Insights",
         "AI-powered summaries of your spending with actionable tips to reach your goals faster."),
        ("creditcard.fill", "Card Optimizer",
         "Always know which Capital One card to use for maximum rewards on every purchase.")
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Pages
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    VStack(spacing: 24) {
                        Spacer()

                        Image(systemName: page.icon)
                            .font(.system(size: 70))
                            .foregroundStyle(CCTheme.primaryBlue)
                            .padding(.bottom, 8)

                        Text(page.title)
                            .font(.title.bold())
                            .foregroundStyle(CCTheme.textPrimary)

                        Text(page.description)
                            .font(.body)
                            .foregroundStyle(CCTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)

                        Spacer()
                        Spacer()
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            // Bottom button
            VStack(spacing: 16) {
                Button {
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        // In production, this would trigger Capital One OAuth flow
                        let userId = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
                        appState.completeOnboarding(userId: userId)
                    }
                } label: {
                    Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(CCTheme.primaryBlue)
                        .clipShape(RoundedRectangle(cornerRadius: CCTheme.cornerRadiusMedium))
                }

                if currentPage < pages.count - 1 {
                    Button("Skip") {
                        let userId = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
                        appState.completeOnboarding(userId: userId)
                    }
                    .font(.subheadline)
                    .foregroundStyle(CCTheme.textSecondary)
                }
            }
            .padding(.horizontal, CCTheme.paddingLarge)
            .padding(.bottom, 40)
        }
    }
}

#Preview {
    OnboardingView()
        .environment(AppState())
}
