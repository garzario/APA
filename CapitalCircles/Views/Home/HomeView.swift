import SwiftUI

struct HomeView: View {
    private let data = MockDataService.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CCTheme.paddingLarge) {
                    // Welcome header
                    welcomeHeader

                    // Quick stats cards
                    quickStatsSection

                    // Active goals
                    activeGoalsSection

                    // Recent transactions
                    recentTransactionsSection
                }
                .padding(.horizontal, CCTheme.paddingMedium)
                .padding(.bottom, CCTheme.paddingLarge)
            }
            .background(CCTheme.backgroundPrimary)
            .navigationTitle("Home")
        }
    }

    // MARK: - Welcome Header

    private var welcomeHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome back,")
                    .font(.subheadline)
                    .foregroundStyle(CCTheme.textSecondary)
                Text(data.currentUser.name.components(separatedBy: " ").first ?? "")
                    .font(.title.bold())
                    .foregroundStyle(CCTheme.textPrimary)
            }
            Spacer()
            Image(systemName: data.currentUser.avatarIcon)
                .font(.system(size: 32))
                .foregroundStyle(CCTheme.primaryBlue)
        }
        .padding(.top, CCTheme.paddingMedium)
    }

    // MARK: - Quick Stats

    private var quickStatsSection: some View {
        HStack(spacing: 12) {
            StatCard(
                title: "This Month",
                value: "$\(Int(data.currentStatement.totalSpent).formatted())",
                subtitle: "\(Int(data.currentStatement.comparedToLastMonth))% vs last month",
                icon: "chart.line.downtrend.xyaxis",
                color: CCTheme.successGreen
            )
            StatCard(
                title: "Circles",
                value: "\(data.circles.count)",
                subtitle: "Active groups",
                icon: "person.3.fill",
                color: CCTheme.primaryBlue
            )
        }
    }

    // MARK: - Active Goals

    private var activeGoalsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Active Goals", action: nil)

            ForEach(allGoals.prefix(3)) { goal in
                GoalProgressCard(goal: goal)
            }
        }
    }

    // MARK: - Recent Transactions

    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Recent Activity", action: nil)

            ForEach(data.currentUser.transactions.prefix(5)) { transaction in
                TransactionRow(transaction: transaction)
            }
        }
    }

    private var allGoals: [Goal] {
        var goals: [Goal] = []
        goals.append(data.personalGoal)
        for circle in data.circles {
            goals.append(contentsOf: circle.goals)
        }
        return goals
    }
}

#Preview {
    HomeView()
        .environment(AppState())
}
