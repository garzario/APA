import SwiftUI
import Charts

struct StatementView: View {
    private let data = MockDataService.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CCTheme.paddingLarge) {
                    // Month summary
                    monthlySummary

                    // Spending chart
                    spendingChart

                    // AI insights
                    insightsSection
                }
                .padding(.horizontal, CCTheme.paddingMedium)
                .padding(.bottom, CCTheme.paddingLarge)
            }
            .background(CCTheme.backgroundPrimary)
            .navigationTitle("Smart Insights")
        }
    }

    // MARK: - Monthly Summary

    private var monthlySummary: some View {
        VStack(spacing: 12) {
            Text("\(data.currentStatement.month) \(String(data.currentStatement.year))")
                .font(.title2.bold())
                .foregroundStyle(CCTheme.textPrimary)

            Text("$\(Int(data.currentStatement.totalSpent).formatted())")
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .foregroundStyle(CCTheme.primaryBlue)

            HStack(spacing: 4) {
                Image(systemName: data.currentStatement.isSpendingUp ? "arrow.up.right" : "arrow.down.right")
                Text("\(abs(Int(data.currentStatement.comparedToLastMonth)))% vs last month")
            }
            .font(.subheadline)
            .foregroundStyle(data.currentStatement.isSpendingUp ? CCTheme.errorRed : CCTheme.successGreen)

            // AI narrative
            Text(data.currentStatement.narrative)
                .font(.subheadline)
                .foregroundStyle(CCTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.top, 4)
        }
        .padding(CCTheme.paddingLarge)
        .frame(maxWidth: .infinity)
        .background(CCTheme.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: CCTheme.cornerRadiusLarge))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }

    // MARK: - Spending Chart

    private var spendingChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Spending Breakdown", action: nil)

            Chart(data.currentStatement.categoryBreakdown) { item in
                BarMark(
                    x: .value("Amount", item.amount),
                    y: .value("Category", item.category.rawValue)
                )
                .foregroundStyle(CCTheme.primaryBlue.gradient)
                .cornerRadius(4)
            }
            .chartXAxis {
                AxisMarks(position: .bottom) { value in
                    AxisValueLabel {
                        if let amount = value.as(Double.self) {
                            Text("$\(Int(amount / 1000))k")
                                .font(.caption2)
                        }
                    }
                }
            }
            .frame(height: 200)
        }
        .padding(CCTheme.paddingMedium)
        .background(CCTheme.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: CCTheme.cornerRadiusMedium))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }

    // MARK: - Insights

    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Insights", action: nil)

            ForEach(data.currentStatement.insights) { insight in
                InsightRow(insight: insight)
            }
        }
    }
}

// MARK: - Insight Row

struct InsightRow: View {
    let insight: Insight

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: insight.type.icon)
                .font(.title3)
                .foregroundStyle(iconColor)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(insight.title)
                    .font(.subheadline.bold())
                    .foregroundStyle(CCTheme.textPrimary)
                Text(insight.description)
                    .font(.caption)
                    .foregroundStyle(CCTheme.textSecondary)
                if let action = insight.actionable {
                    Text(action)
                        .font(.caption)
                        .foregroundStyle(CCTheme.accentBlue)
                        .padding(.top, 2)
                }
            }
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
        case .milestone: return Color.yellow
        }
    }
}

#Preview {
    StatementView()
}
