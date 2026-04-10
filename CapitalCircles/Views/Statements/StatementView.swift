import SwiftUI
import Charts

struct StatementView: View {
    @Environment(AppStateManager.self) private var state
    @State private var isRefreshing = false
    @State private var errorMessage: String?
    @State private var showInfoSheet = false
    @State private var expandedInsightId: UUID?

    private var statement: SmartStatement? {
        state.currentStatement
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CCTheme.space7) {
                if let statement {
                    monthPicker
                    heroSection(statement)
                    insightsSection(statement)
                    narrativeSection(statement)
                    chartSection(statement)
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showInfoSheet = true
                } label: {
                    Image(systemName: "info.circle")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundStyle(CCTheme.ink)
                }
            }
        }
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

    // MARK: - Month picker (history)

    private var monthPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: CCTheme.space2) {
                ForEach(state.statements) { stmt in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            state.selectedStatementId = stmt.id
                            expandedInsightId = nil
                        }
                    } label: {
                        let isSelected = stmt.id == (state.selectedStatementId ?? state.statements.last?.id)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(stmt.month.uppercased())
                                .font(.ccCaption)
                                .foregroundStyle(isSelected ? .white : CCTheme.slate)
                                .tracking(0.5)
                            Text("$\(Int(stmt.totalSpent / 1000))K")
                                .font(.ccHeadline)
                                .foregroundStyle(isSelected ? .white : CCTheme.ink)
                                .monospacedDigit()
                        }
                        .padding(.horizontal, CCTheme.space4)
                        .padding(.vertical, CCTheme.space3)
                        .background(isSelected ? CCTheme.navy : CCTheme.fog)
                        .clipShape(RoundedRectangle(cornerRadius: CCTheme.radiusMedium))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, CCTheme.space5)
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
                Image(systemName: statement.isSpendingUp ? "arrow.up.right" : "arrow.down.right")
                    .font(.system(size: 12, weight: .semibold))
                Text("\(abs(Int(statement.comparedToLastMonth)))% vs last month")
                    .font(.ccSubhead)
            }
            .foregroundStyle(statement.isSpendingUp ? CCTheme.red : CCTheme.positive)
        }
        .padding(.horizontal, CCTheme.space5)
    }

    // MARK: - Insights (What we noticed) - ABOVE the fold, interactive

    private func insightsSection(_ statement: SmartStatement) -> some View {
        VStack(alignment: .leading, spacing: CCTheme.space4) {
            HStack {
                VStack(alignment: .leading, spacing: CCTheme.space1) {
                    Text("WHAT WE NOTICED")
                        .font(.ccCaption)
                        .foregroundStyle(CCTheme.slate)
                        .tracking(0.5)
                    Text("AI insights for you")
                        .font(.ccTitle)
                        .foregroundStyle(CCTheme.ink)
                }
                Spacer()
                Button {
                    Task { await regenerate() }
                } label: {
                    HStack(spacing: 6) {
                        if isRefreshing {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        Text(isRefreshing ? "Working" : "Refresh")
                            .font(.ccFootnote.bold())
                    }
                    .foregroundStyle(CCTheme.navy)
                    .padding(.horizontal, CCTheme.space4)
                    .padding(.vertical, CCTheme.space2 + 2)
                    .background(CCTheme.fog)
                    .clipShape(Capsule())
                }
                .disabled(isRefreshing)
            }
            .padding(.horizontal, CCTheme.space5)

            VStack(spacing: CCTheme.space3) {
                ForEach(statement.insights) { insight in
                    insightCard(insight)
                }
            }
            .padding(.horizontal, CCTheme.space5)
        }
    }

    private func insightCard(_ insight: Insight) -> some View {
        let isExpanded = expandedInsightId == insight.id

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                expandedInsightId = isExpanded ? nil : insight.id
            }
        } label: {
            VStack(alignment: .leading, spacing: CCTheme.space3) {
                HStack(alignment: .top, spacing: CCTheme.space3) {
                    Image(systemName: iconFor(insight.type))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(colorFor(insight.type))
                        .frame(width: 36, height: 36)
                        .background(colorFor(insight.type).opacity(0.12))
                        .clipShape(SwiftUI.Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        Text(insight.title)
                            .font(.ccBody.bold())
                            .foregroundStyle(CCTheme.ink)
                            .multilineTextAlignment(.leading)
                        Text(insight.description)
                            .font(.ccFootnote)
                            .foregroundStyle(CCTheme.slate)
                            .multilineTextAlignment(.leading)
                            .lineSpacing(2)
                    }

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(CCTheme.mist)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }

                if isExpanded, let action = insight.actionable, !action.isEmpty {
                    HStack(spacing: CCTheme.space2) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(CCTheme.navy)
                        Text(action)
                            .font(.ccFootnote)
                            .foregroundStyle(CCTheme.ink)
                    }
                    .padding(CCTheme.space3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(CCTheme.cream)
                    .clipShape(RoundedRectangle(cornerRadius: CCTheme.radiusSmall))
                }
            }
            .padding(CCTheme.space4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(CCTheme.canvas)
            .overlay {
                RoundedRectangle(cornerRadius: CCTheme.radiusMedium)
                    .stroke(CCTheme.hairline, lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: CCTheme.radiusMedium))
        }
        .buttonStyle(.plain)
    }

    private func iconFor(_ type: InsightType) -> String {
        switch type {
        case .positive: return "arrow.down.circle"
        case .warning: return "exclamationmark.circle"
        case .tip: return "lightbulb"
        case .milestone: return "flag.checkered"
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

    // MARK: - Narrative (summary)

    private func narrativeSection(_ statement: SmartStatement) -> some View {
        VStack(alignment: .leading, spacing: CCTheme.space3) {
            Text("SUMMARY")
                .font(.ccCaption)
                .foregroundStyle(CCTheme.slate)
                .tracking(0.5)

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

    // MARK: - Regenerate

    private func regenerate() async {
        guard let statement else { return }
        isRefreshing = true
        defer { isRefreshing = false }

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
                            body: "Only anonymized spending categories and totals are used. Merchant names never leave your device."
                        )
                        infoRow(
                            number: "2",
                            title: "Tailored to your circle",
                            body: "Insights reference your circle members and shared goals so the advice feels personal."
                        )
                        infoRow(
                            number: "3",
                            title: "Fresh every time",
                            body: "Tap refresh for a new take on the same data. Different angles, same honesty."
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
