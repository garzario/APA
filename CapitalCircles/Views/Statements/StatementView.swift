import SwiftUI
import Charts

struct StatementView: View {
    @Environment(AppStateManager.self) private var state
    @State private var isRefreshing = false
    @State private var errorMessage: String?
    @State private var showInfoSheet = false

    private var statement: SmartStatement? {
        state.currentStatement
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CCTheme.space7) {
                if let statement {
                    heroSection(statement)
                    refreshCard
                    narrativeSection(statement)
                    chartSection(statement)
                    insightsSection(statement)
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, CCTheme.space9)
                }
            }
            .padding(.vertical, CCTheme.space5)
            .padding(.bottom, CCTheme.space8)
        }
        .background(CCTheme.canvas)
        .navigationTitle("Insights")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Could not refresh", isPresented: .init(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
        .sheet(isPresented: $showInfoSheet) {
            AIInfoSheet()
                .presentationDetents([.medium])
        }
    }

    // MARK: - Hero

    private func heroSection(_ statement: SmartStatement) -> some View {
        VStack(alignment: .leading, spacing: CCTheme.space3) {
            Text("\(statement.month.uppercased()) \(String(statement.year))")
                .font(.ccCaption)
                .foregroundStyle(CCTheme.slate)
                .tracking(0.5)

            Text("You spent")
                .font(.ccTitle)
                .foregroundStyle(CCTheme.slate)

            Text("$\(Int(statement.totalSpent).formatted())")
                .font(.ccAmountLarge)
                .foregroundStyle(CCTheme.ink)
                .monospacedDigit()

            HStack(spacing: CCTheme.space2) {
                Image(systemName: statement.isSpendingUp ? "arrow.up" : "arrow.down")
                    .font(.system(size: 12, weight: .semibold))
                Text("\(abs(Int(statement.comparedToLastMonth)))% vs last month")
                    .font(.ccSubhead)
            }
            .foregroundStyle(statement.isSpendingUp ? CCTheme.red : CCTheme.positive)
        }
        .padding(.horizontal, CCTheme.space5)
    }

    // MARK: - Refresh Card (explains and offers AI regeneration)

    private var refreshCard: some View {
        Button {
            Task { await regenerate() }
        } label: {
            VStack(alignment: .leading, spacing: CCTheme.space4) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: CCTheme.space2) {
                        HStack(spacing: CCTheme.space2) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 13, weight: .semibold))
                            Text("AI INSIGHTS")
                                .font(.ccCaption)
                                .tracking(0.5)
                        }
                        .foregroundStyle(.white.opacity(0.85))

                        Text("Fresh take, any time")
                            .font(.ccTitle)
                            .foregroundStyle(.white)
                    }
                    Spacer()
                    if isRefreshing {
                        ProgressView()
                            .controlSize(.regular)
                            .tint(.white)
                    } else {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(.white.opacity(0.15))
                            .clipShape(SwiftUI.Circle())
                    }
                }

                Text("Generate a new summary based on your spending this month. Tap refresh for a different angle on your numbers, tailored to you and your circle.")
                    .font(.ccFootnote)
                    .foregroundStyle(.white.opacity(0.9))
                    .lineSpacing(3)

                Button {
                    showInfoSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Text("How it works")
                            .font(.ccFootnote.bold())
                        Image(systemName: "info.circle")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
            }
            .padding(CCTheme.space5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(CCTheme.navy)
            .clipShape(RoundedRectangle(cornerRadius: CCTheme.radiusLarge))
        }
        .buttonStyle(.plain)
        .disabled(isRefreshing)
        .padding(.horizontal, CCTheme.space5)
    }

    // MARK: - Narrative

    private func narrativeSection(_ statement: SmartStatement) -> some View {
        VStack(alignment: .leading, spacing: CCTheme.space3) {
            HStack(spacing: CCTheme.space2) {
                Image(systemName: "quote.opening")
                    .font(.system(size: 12, weight: .medium))
                Text("SUMMARY")
                    .font(.ccCaption)
                    .tracking(0.5)
            }
            .foregroundStyle(CCTheme.navy)

            Text(statement.narrative)
                .font(.ccBody)
                .foregroundStyle(CCTheme.ink)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(CCTheme.space5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CCTheme.cream)
        .clipShape(RoundedRectangle(cornerRadius: CCTheme.radiusMedium))
        .padding(.horizontal, CCTheme.space5)
    }

    // MARK: - Chart

    private func chartSection(_ statement: SmartStatement) -> some View {
        CCSection("Where it went") {
            VStack(spacing: 0) {
                Divider()
                ForEach(Array(statement.categoryBreakdown.enumerated()), id: \.element.id) { index, item in
                    categoryRow(item: item, maxAmount: statement.categoryBreakdown.map { $0.amount }.max() ?? 1)
                    if index < statement.categoryBreakdown.count - 1 {
                        Divider().padding(.leading, CCTheme.space5)
                    }
                }
                Divider()
            }
        }
    }

    private func categoryRow(item: CategorySpending, maxAmount: Double) -> some View {
        VStack(alignment: .leading, spacing: CCTheme.space2) {
            HStack {
                Text(item.category.rawValue)
                    .font(.ccBody)
                    .foregroundStyle(CCTheme.ink)
                Spacer()
                Text("$\(Int(item.amount).formatted())")
                    .font(.ccBody)
                    .foregroundStyle(CCTheme.ink)
                    .monospacedDigit()
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(CCTheme.hairline)
                        .frame(height: 3)
                    Capsule()
                        .fill(CCTheme.navy)
                        .frame(width: geo.size.width * (item.amount / maxAmount), height: 3)
                }
            }
            .frame(height: 3)
        }
        .padding(.horizontal, CCTheme.space5)
        .padding(.vertical, CCTheme.space3)
    }

    // MARK: - Insights

    private func insightsSection(_ statement: SmartStatement) -> some View {
        CCSection("What we noticed") {
            VStack(spacing: 0) {
                Divider()
                ForEach(Array(statement.insights.enumerated()), id: \.element.id) { index, insight in
                    insightRow(insight)
                    if index < statement.insights.count - 1 {
                        Divider().padding(.leading, CCTheme.space5)
                    }
                }
                Divider()
            }
        }
    }

    private func insightRow(_ insight: Insight) -> some View {
        HStack(alignment: .top, spacing: CCTheme.space4) {
            Image(systemName: iconFor(insight.type))
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(colorFor(insight.type))
                .frame(width: 28, alignment: .center)

            VStack(alignment: .leading, spacing: 4) {
                Text(insight.title)
                    .font(.ccBody)
                    .foregroundStyle(CCTheme.ink)
                Text(insight.description)
                    .font(.ccFootnote)
                    .foregroundStyle(CCTheme.slate)
                if let action = insight.actionable, !action.isEmpty {
                    Text(action)
                        .font(.ccFootnote)
                        .foregroundStyle(CCTheme.navy)
                        .padding(.top, 2)
                }
            }
            Spacer()
        }
        .padding(.horizontal, CCTheme.space5)
        .padding(.vertical, CCTheme.space4)
    }

    private func iconFor(_ type: InsightType) -> String {
        switch type {
        case .positive: return "arrow.down.circle"
        case .warning: return "exclamationmark.circle"
        case .tip: return "lightbulb"
        case .milestone: return "checkmark.circle"
        }
    }

    private func colorFor(_ type: InsightType) -> Color {
        switch type {
        case .positive: return CCTheme.positive
        case .warning: return CCTheme.red
        case .tip: return CCTheme.navy
        case .milestone: return CCTheme.gold
        }
    }

    // MARK: - Regenerate

    private func regenerate() async {
        guard let statement else { return }
        isRefreshing = true
        defer { isRefreshing = false }

        // Build context from state for a more human, personalized response
        let circle = state.circles.first(where: { $0.type == .family }) ?? state.circles.first
        let context = ClaudeService.Context(
            userName: state.currentUser.name.components(separatedBy: " ").first ?? state.currentUser.name,
            circleName: circle?.name,
            circleMembers: circle?.members.map { $0.user.name.components(separatedBy: " ").first ?? $0.user.name } ?? [],
            sharedGoals: circle?.goals.map { ($0.title, $0.progressPercentage) } ?? [],
            personalGoals: state.personalGoals.map { ($0.title, $0.progressPercentage) }
        )

        do {
            let generated = try await ClaudeService.generateSmartStatement(
                month: statement.month,
                year: statement.year,
                totalSpent: statement.totalSpent,
                comparedToLastMonth: statement.comparedToLastMonth,
                categories: statement.categoryBreakdown,
                context: context
            )

            let updated = SmartStatement(
                id: statement.id,
                month: statement.month,
                year: statement.year,
                narrative: generated.narrative,
                totalSpent: statement.totalSpent,
                insights: generated.insights.map { gen in
                    Insight(
                        id: UUID(),
                        title: gen.title,
                        description: gen.description,
                        type: InsightType(rawValue: gen.type) ?? .tip,
                        actionable: gen.actionable
                    )
                },
                categoryBreakdown: statement.categoryBreakdown,
                comparedToLastMonth: statement.comparedToLastMonth
            )
            state.currentStatement = updated
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - AI Info Sheet

struct AIInfoSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: CCTheme.space6) {
                    VStack(alignment: .leading, spacing: CCTheme.space2) {
                        Text("HOW IT WORKS")
                            .font(.ccCaption)
                            .foregroundStyle(CCTheme.slate)
                            .tracking(0.5)
                        Text("AI insights,\nthoughtfully generated")
                            .font(.ccLargeTitle)
                            .foregroundStyle(CCTheme.ink)
                    }

                    VStack(alignment: .leading, spacing: CCTheme.space5) {
                        infoRow(
                            number: "1",
                            title: "Your data stays yours",
                            body: "Only anonymized spending categories and totals are used to generate insights. Merchant names never leave your device."
                        )
                        infoRow(
                            number: "2",
                            title: "Tailored to your circle",
                            body: "Insights reference your circle members and shared goals so the advice feels personal and relevant."
                        )
                        infoRow(
                            number: "3",
                            title: "Fresh every time",
                            body: "Tap refresh whenever you want a new take on the same data. Different angles, same honesty."
                        )
                    }
                }
                .padding(CCTheme.space5)
                .padding(.bottom, CCTheme.space7)
            }
            .background(CCTheme.canvas)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(CCTheme.ink)
                    }
                }
            }
        }
    }

    private func infoRow(number: String, title: String, body: String) -> some View {
        HStack(alignment: .top, spacing: CCTheme.space4) {
            Text(number)
                .font(.ccHeadline)
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(CCTheme.navy)
                .clipShape(SwiftUI.Circle())
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.ccBody.bold())
                    .foregroundStyle(CCTheme.ink)
                Text(body)
                    .font(.ccFootnote)
                    .foregroundStyle(CCTheme.slate)
                    .lineSpacing(3)
            }
        }
    }
}
