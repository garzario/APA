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
            VStack(spacing: CCTheme.paddingLarge) {
                if let statement {
                    heroSummary(statement)
                    narrativeCard(statement)
                    spendingChart(statement)
                    insightsSection(statement)
                    regenerateButton
                } else {
                    ProgressView("Loading insights")
                        .padding()
                }
            }
            .padding(.horizontal, CCTheme.paddingMedium)
            .padding(.bottom, CCTheme.paddingLarge)
        }
        .background(CCTheme.backgroundPrimary)
        .navigationTitle("Smart Insights")
        .alert("Could not refresh", isPresented: .init(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    // MARK: - Hero Summary

    private func heroSummary(_ statement: SmartStatement) -> some View {
        VStack(spacing: 12) {
            Text("\(statement.month) \(String(statement.year))")
                .font(.subheadline.bold())
                .foregroundStyle(.white.opacity(0.9))

            Text("$\(Int(statement.totalSpent).formatted())")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            HStack(spacing: 6) {
                Image(systemName: statement.isSpendingUp ? "arrow.up.right" : "arrow.down.right")
                Text("\(abs(Int(statement.comparedToLastMonth)))% vs last month")
            }
            .font(.subheadline.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.white.opacity(0.2))
            .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity)
        .padding(CCTheme.paddingLarge)
        .background(
            LinearGradient(
                colors: [CCTheme.primaryBlue, CCTheme.accentBlue],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: CCTheme.cornerRadiusLarge))
        .shadow(color: CCTheme.primaryBlue.opacity(0.3), radius: 16, y: 6)
    }

    // MARK: - Narrative

    private func narrativeCard(_ statement: SmartStatement) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .foregroundStyle(CCTheme.accentBlue)
                Text("AI summary")
                    .font(.caption.bold())
                    .foregroundStyle(CCTheme.accentBlue)
            }
            Text(statement.narrative)
                .font(.subheadline)
                .foregroundStyle(CCTheme.textPrimary)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(CCTheme.paddingMedium)
        .background(CCTheme.lightBlue.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: CCTheme.cornerRadiusMedium))
    }

    // MARK: - Chart

    private func spendingChart(_ statement: SmartStatement) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Spending breakdown")
                .font(.headline)
                .foregroundStyle(CCTheme.textPrimary)

            Chart(statement.categoryBreakdown) { item in
                BarMark(
                    x: .value("Amount", item.amount),
                    y: .value("Category", item.category.rawValue)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [CCTheme.primaryBlue, CCTheme.accentBlue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(6)
                .annotation(position: .trailing) {
                    Text("$\(Int(item.amount).formatted())")
                        .font(.caption2.bold())
                        .foregroundStyle(CCTheme.textSecondary)
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisValueLabel()
                        .font(.caption2)
                }
            }
            .frame(height: 260)
        }
        .padding(CCTheme.paddingMedium)
        .background(CCTheme.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: CCTheme.cornerRadiusMedium))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }

    // MARK: - Insights

    private func insightsSection(_ statement: SmartStatement) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Insights")
                .font(.headline)
                .foregroundStyle(CCTheme.textPrimary)

            ForEach(statement.insights) { insight in
                InsightRow(insight: insight)
            }
        }
    }

    // MARK: - Regenerate Button

    private var regenerateButton: some View {
        Button {
            Task { await regenerate() }
        } label: {
            HStack(spacing: 8) {
                if isRefreshing {
                    ProgressView()
                        .controlSize(.small)
                        .tint(.white)
                } else {
                    Image(systemName: "arrow.clockwise")
                }
                Text(isRefreshing ? "Generating..." : "Refresh with AI")
            }
            .font(.subheadline.bold())
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(CCTheme.primaryBlue)
            .clipShape(RoundedRectangle(cornerRadius: CCTheme.cornerRadiusMedium))
        }
        .disabled(isRefreshing)
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

// MARK: - Insight Row

struct InsightRow: View {
    let insight: Insight

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: insight.type.icon)
                .font(.title3)
                .foregroundStyle(iconColor)
                .frame(width: 40, height: 40)
                .background(iconBackground)
                .clipShape(SwiftUI.Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(insight.title)
                    .font(.subheadline.bold())
                    .foregroundStyle(CCTheme.textPrimary)
                Text(insight.description)
                    .font(.caption)
                    .foregroundStyle(CCTheme.textSecondary)
                if let action = insight.actionable {
                    Text(action)
                        .font(.caption.bold())
                        .foregroundStyle(CCTheme.accentBlue)
                        .padding(.top, 2)
                }
            }
            Spacer()
        }
        .padding(CCTheme.paddingMedium)
        .background(CCTheme.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: CCTheme.cornerRadiusMedium))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }

    private var iconColor: Color {
        switch insight.type {
        case .positive: return CCTheme.successGreen
        case .warning: return CCTheme.warningOrange
        case .tip: return CCTheme.accentBlue
        case .milestone: return .yellow
        }
    }

    private var iconBackground: Color {
        switch insight.type {
        case .positive: return CCTheme.successGreen.opacity(0.15)
        case .warning: return CCTheme.warningOrange.opacity(0.15)
        case .tip: return CCTheme.lightBlue
        case .milestone: return Color.yellow.opacity(0.15)
        }
    }
}
