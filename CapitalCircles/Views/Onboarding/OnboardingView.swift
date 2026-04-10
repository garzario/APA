import SwiftUI

struct OnboardingView: View {
    @Environment(AppState.self) private var appState
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            eyebrow: "Welcome",
            title: "Your family's\nfinancial home",
            body: "Capital Circles is a new way to reach your financial goals. Together, privately, and powered by Capital One."
        ),
        OnboardingPage(
            eyebrow: "Circles",
            title: "Better together,\nstill yours alone",
            body: "Create circles with family, friends, and roommates to support each other without combining finances."
        ),
        OnboardingPage(
            eyebrow: "Privacy",
            title: "Your money\nstays your money",
            body: "You choose what to share, with whom, and how much. Nothing is visible unless you opt in."
        ),
        OnboardingPage(
            eyebrow: "Insights",
            title: "Smarter spending,\nwithout the work",
            body: "Monthly AI summaries of your spending with honest, actionable tips to reach your goals faster."
        ),
        OnboardingPage(
            eyebrow: "Cards",
            title: "Every purchase,\noptimized",
            body: "Always know which Capital One card earns the best rewards for what you are buying."
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    pageView(page)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            VStack(spacing: CCTheme.space4) {
                HStack(spacing: 6) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule()
                            .fill(currentPage == index ? CCTheme.navy : CCTheme.hairline)
                            .frame(width: currentPage == index ? 24 : 6, height: 6)
                            .animation(.easeInOut(duration: 0.25), value: currentPage)
                    }
                }

                Button {
                    if currentPage < pages.count - 1 {
                        withAnimation { currentPage += 1 }
                    } else {
                        complete()
                    }
                } label: {
                    Text(currentPage < pages.count - 1 ? "Continue" : "Get started")
                }
                .buttonStyle(CCPrimaryButtonStyle())

                if currentPage < pages.count - 1 {
                    Button { complete() } label: {
                        Text("Skip")
                            .font(.ccBody)
                            .foregroundStyle(CCTheme.slate)
                    }
                } else {
                    Color.clear.frame(height: 22)
                }
            }
            .padding(.horizontal, CCTheme.space5)
            .padding(.bottom, CCTheme.space6)
        }
        .background(CCTheme.canvas)
    }

    private func pageView(_ page: OnboardingPage) -> some View {
        VStack(alignment: .leading, spacing: CCTheme.space5) {
            Spacer()

            Text(page.eyebrow.uppercased())
                .font(.ccCaption)
                .foregroundStyle(CCTheme.slate)
                .tracking(0.5)

            Text(page.title)
                .font(.system(size: 38, weight: .bold, design: .default))
                .foregroundStyle(CCTheme.ink)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)

            Text(page.body)
                .font(.ccBody)
                .foregroundStyle(CCTheme.slate)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, CCTheme.space5)
    }

    private func complete() {
        let userId = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
        appState.completeOnboarding(userId: userId)
    }
}

private struct OnboardingPage {
    let eyebrow: String
    let title: String
    let body: String
}
