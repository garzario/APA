import SwiftUI

struct HomeView: View {
    @Environment(AppStateManager.self) private var state
    @State private var showNotifications = false
    @State private var selectedTransaction: Transaction?
    @State private var selectedGoal: Goal?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CCTheme.paddingLarge) {
                    heroHeader
                    monthlySpendingCard
                    goalsSection
                    recentActivitySection
                }
                .padding(.horizontal, CCTheme.paddingMedium)
                .padding(.bottom, CCTheme.paddingLarge * 2)
            }
            .background(CCTheme.backgroundPrimary)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 10) {
                        Image(systemName: "circle.grid.3x3.circle.fill")
                            .font(.title3)
                            .foregroundStyle(CCTheme.primaryBlue)
                        Text("Capital Circles")
                            .font(.headline)
                            .foregroundStyle(CCTheme.textPrimary)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showNotifications = true
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "bell.fill")
                                .foregroundStyle(CCTheme.primaryBlue)
                                .font(.title3)
                            if state.unreadNotificationCount > 0 {
                                Circle()
                                    .fill(CCTheme.errorRed)
                                    .frame(width: 8, height: 8)
                                    .offset(x: 3, y: -2)
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showNotifications) {
                NotificationsView()
            }
            .sheet(item: $selectedTransaction) { transaction in
                TransactionDetailView(transaction: transaction)
            }
            .sheet(item: $selectedGoal) { goal in
                GoalDetailView(goal: goal)
            }
        }
    }

    // MARK: - Hero Header

    private var heroHeader: some View {
        HStack(alignment: .center, spacing: 14) {
            Image(systemName: state.currentUser.avatarIcon)
                .font(.system(size: 44))
                .foregroundStyle(CCTheme.primaryBlue)
                .frame(width: 56, height: 56)
                .background(CCTheme.lightBlue)
                .clipShape(SwiftUI.Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text("Welcome back")
                    .font(.caption)
                    .foregroundStyle(CCTheme.textSecondary)
                Text(state.currentUser.name.components(separatedBy: " ").first ?? "")
                    .font(.title2.bold())
                    .foregroundStyle(CCTheme.textPrimary)
            }
            Spacer()
        }
        .padding(.top, 4)
    }

    // MARK: - Monthly Spending Card

    private var monthlySpendingCard: some View {
        NavigationLink(destination: StatementView()) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("This month")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.8))
                        Text("$\(Int(state.totalSpentThisMonth).formatted())")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    Spacer()
                    Image(systemName: "sparkles")
                        .font(.title2)
                        .foregroundStyle(.white.opacity(0.9))
                }

                HStack(spacing: 8) {
                    let change = state.currentStatement?.comparedToLastMonth ?? 0
                    Image(systemName: change < 0 ? "arrow.down.right" : "arrow.up.right")
                        .font(.caption.bold())
                    Text("\(abs(Int(change)))% vs last month")
                        .font(.caption.bold())
                    Spacer()
                    Text("Tap for insights")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.7))
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.7))
                }
                .foregroundStyle(.white.opacity(0.95))
                .padding(.vertical, 8)
                .padding(.horizontal, 10)
                .background(.white.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(CCTheme.paddingLarge)
            .frame(maxWidth: .infinity, alignment: .leading)
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
        .buttonStyle(.plain)
    }

    // MARK: - Goals Section

    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Active goals")
                    .font(.title3.bold())
                    .foregroundStyle(CCTheme.textPrimary)
                Spacer()
                NavigationLink(destination: GoalsListView()) {
                    Text("See all")
                        .font(.subheadline)
                        .foregroundStyle(CCTheme.accentBlue)
                }
            }

            let goals = state.allGoals.sorted { $0.progressPercentage > $1.progressPercentage }.prefix(3)
            if goals.isEmpty {
                EmptyStateCard(
                    icon: "target",
                    title: "No goals yet",
                    message: "Create your first goal to start tracking progress"
                )
            } else {
                ForEach(Array(goals)) { goal in
                    Button {
                        selectedGoal = goal
                    } label: {
                        GoalProgressCard(goal: goal)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Recent Activity

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent activity")
                    .font(.title3.bold())
                    .foregroundStyle(CCTheme.textPrimary)
                Spacer()
            }

            VStack(spacing: 0) {
                ForEach(state.transactions.prefix(5)) { transaction in
                    Button {
                        selectedTransaction = transaction
                    } label: {
                        TransactionRow(transaction: transaction)
                    }
                    .buttonStyle(.plain)
                    if transaction.id != state.transactions.prefix(5).last?.id {
                        Divider()
                            .padding(.leading, 56)
                    }
                }
            }
            .padding(.horizontal, CCTheme.paddingMedium)
            .background(CCTheme.backgroundCard)
            .clipShape(RoundedRectangle(cornerRadius: CCTheme.cornerRadiusMedium))
            .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
        }
    }
}

#Preview {
    HomeView()
        .environment(AppStateManager.shared)
        .environment(AppState())
}
