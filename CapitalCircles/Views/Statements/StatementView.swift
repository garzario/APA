import SwiftUI
import Charts

struct StatementView: View {
    @Environment(AppStateManager.self) private var state
    @State private var isRefreshing = false
    @State private var errorMessage: String?

    private var statement: SmartStatement? {
        state.currentStatement
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CCTheme.space8) {
                if let statement {
                    heroSection(statement)
                    narrativeSection(statement)
                    chartSection(statement)
                    insightsSection(statement)
                    refreshSection
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
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Insights")
                    .font(.ccHeadline)
                    .foregroundStyle(CCTheme.ink)
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

    // MARK: - Narrative

    private func narrativeSection(_ statement: SmartStatement) -> some View {
        VStack(alignment: .leading, spacing: CCTheme.space3) {
            HStack(spacing: CCTheme.space2) {
                Image(systemName: "sparkles")
                    .font(.system(size: 12, weight: .medium))
                Text("AI SUMMARY")
                    .font(.ccCaption)
                    .tracking(0.5)
            }
            .foregroundStyle(CCTheme.navy)

            Text(statement.narrative)
                .font(.ccBody)
                .foregroundStyle(CCTheme.ink)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(CCTheme.space5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CCTheme.fog)
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
                if let action = insight.actionable {
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
        case .warning: return CCTheme.caution
        case .tip: return CCTheme.navy
        case .milestone: return CCTheme.positive
        }
    }

    // MARK: - Refresh

    private var refreshSection: some View {
        Button {
            Task { await regenerate() }
        } label: {
            HStack(spacing: CCTheme.space2) {
                if isRefreshing {
                    ProgressView()
                        .controlSize(.small)
                        .tint(.white)
                } else {
                    Image(systemName: "arrow.clockwise")
                }
                Text(isRefreshing ? "Generating…" : "Refresh insights")
            }
        }
        .buttonStyle(CCPrimaryButtonStyle())
        .disabled(isRefreshing)
        .padding(.horizontal, CCTheme.space5)
    }

    private func regenerate() async {
        guard let statement else { return }
        isRefreshing = true
        defer { isRefreshing = false }

        do {
            let generated = try await ClaudeService.generateSmartStatement(
                month: statement.month,
                year: statement.year,
                totalSpent: statement.totalSpent,
                comparedToLastMonth: statement.comparedToLastMonth,
                categories: statement.categoryBreakdown
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
