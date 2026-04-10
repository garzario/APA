import SwiftUI

struct OnboardingView: View {
    @Environment(AppState.self) private var appState
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "circle.grid.3x3.circle.fill",
            title: "Welcome to Capital Circles",
            description: "A new way to reach your financial goals. Together, privately, intelligently.",
            color: CCTheme.primaryBlue
        ),
        OnboardingPage(
            icon: "person.3.fill",
            title: "Better together",
            description: "Create circles with family, friends, and roommates to support each other without combining finances.",
            color: CCTheme.accentBlue
        ),
        OnboardingPage(
            icon: "lock.shield.fill",
            title: "Privacy first",
            description: "Your finances stay private. You choose what to share, with whom, and how much.",
            color: CCTheme.successGreen
        ),
        OnboardingPage(
            icon: "sparkles",
            title: "Smart insights",
            description: "AI-powered monthly summaries with actionable tips to reach your goals faster.",
            color: CCTheme.warningOrange
        ),
        OnboardingPage(
            icon: "creditcard.fill",
            title: "Capital One native",
            description: "Always know which of your Capital One cards earns the best rewards for every purchase.",
            color: CCTheme.primaryBlue
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    VStack(spacing: 28) {
                        Spacer()

                        Image(systemName: page.icon)
                            .font(.system(size: 80))
                            .foregroundStyle(.white)
                            .frame(width: 140, height: 140)
                            .background(
                                LinearGradient(
                                    colors: [page.color, page.color.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 32))
                            .shadow(color: page.color.opacity(0.4), radius: 20, y: 10)

                        VStack(spacing: 14) {
                            Text(page.title)
                                .font(.largeTitle.bold())
                                .foregroundStyle(CCTheme.textPrimary)
                                .multilineTextAlignment(.center)

                            Text(page.description)
                                .font(.body)
                                .foregroundStyle(CCTheme.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }

                        Spacer()
                        Spacer()
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            VStack(spacing: 14) {
                Button {
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        complete()
                    }
                } label: {
                    Text(currentPage < pages.count - 1 ? "Continue" : "Get started")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(CCTheme.primaryBlue)
                        .clipShape(RoundedRectangle(cornerRadius: CCTheme.cornerRadiusMedium))
                }

                if currentPage < pages.count - 1 {
                    Button("Skip intro") { complete() }
                        .font(.subheadline)
                        .foregroundStyle(CCTheme.textSecondary)
                }
            }
            .padding(.horizontal, CCTheme.paddingLarge)
            .padding(.bottom, 40)
        }
        .background(CCTheme.backgroundPrimary)
    }

    private func complete() {
        let userId = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
        appState.completeOnboarding(userId: userId)
    }
}

private struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let color: Color
}
