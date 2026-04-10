import SwiftUI

struct GoalsListView: View {
    @Environment(AppStateManager.self) private var state
    @State private var showCreateGoal = false
    @State private var selectedGoal: Goal?
    @State private var filter: GoalFilter = .all

    enum GoalFilter: String, CaseIterable {
        case all = "All"
        case personal = "Personal"
        case shared = "Shared"
    }

    private var filteredGoals: [Goal] {
        switch filter {
        case .all: return state.allGoals
        case .personal: return state.personalGoals
        case .shared: return state.circles.flatMap { $0.goals }
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: CCTheme.paddingMedium) {
                // Filter pills
                Picker("Filter", selection: $filter) {
                    ForEach(GoalFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.top, CCTheme.paddingSmall)

                // Summary
                summaryCard

                // Goals list
                if filteredGoals.isEmpty {
                    EmptyStateCard(
                        icon: "target",
                        title: "No goals yet",
                        message: "Start tracking what matters most to you",
                        actionLabel: "Create goal",
                        action: { showCreateGoal = true }
                    )
                } else {
                    ForEach(filteredGoals) { goal in
                        Button {
                            selectedGoal = goal
                        } label: {
                            GoalProgressCard(goal: goal)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, CCTheme.paddingMedium)
            .padding(.bottom, CCTheme.paddingLarge)
        }
        .background(CCTheme.backgroundPrimary)
        .navigationTitle("Goals")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showCreateGoal = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(CCTheme.primaryBlue)
                }
            }
        }
        .sheet(isPresented: $showCreateGoal) {
            CreateGoalView()
        }
        .sheet(item: $selectedGoal) { goal in
            GoalDetailView(goal: goal)
        }
    }

    private var summaryCard: some View {
        HStack(spacing: 12) {
            StatCard(
                title: "Total saved",
                value: "$\(Int(state.totalSaved).formatted())",
                subtitle: "Across \(state.allGoals.count) goals",
                icon: "dollarsign.circle.fill",
                color: CCTheme.successGreen
            )
            let completed = state.allGoals.filter { $0.isCompleted }.count
            StatCard(
                title: "Completed",
                value: "\(completed)",
                subtitle: "Goals reached",
                icon: "checkmark.circle.fill",
                color: CCTheme.primaryBlue
            )
        }
    }
}

#Preview {
    NavigationStack {
        GoalsListView()
            .environment(AppStateManager.shared)
    }
}
