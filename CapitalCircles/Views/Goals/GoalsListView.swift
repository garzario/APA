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
            VStack(alignment: .leading, spacing: CCTheme.space7) {
                header

                filterPicker

                if filteredGoals.isEmpty {
                    emptyState
                } else {
                    goalsList
                }
            }
            .padding(.vertical, CCTheme.space5)
            .padding(.bottom, CCTheme.space8)
        }
        .background(CCTheme.canvas)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Goals")
                    .font(.ccHeadline)
                    .foregroundStyle(CCTheme.ink)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showCreateGoal = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(CCTheme.ink)
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

    private var header: some View {
        VStack(alignment: .leading, spacing: CCTheme.space3) {
            Text("TOTAL SAVED")
                .font(.ccCaption)
                .foregroundStyle(CCTheme.slate)
                .tracking(0.5)
            Text("$\(Int(state.totalSaved).formatted())")
                .font(.ccAmountLarge)
                .foregroundStyle(CCTheme.ink)
                .monospacedDigit()
            HStack(spacing: CCTheme.space2) {
                Text("Across \(state.allGoals.count) goals")
                Text("•")
                    .foregroundStyle(CCTheme.mist)
                let completed = state.allGoals.filter { $0.isCompleted }.count
                Text("\(completed) completed")
            }
            .font(.ccSubhead)
            .foregroundStyle(CCTheme.slate)
        }
        .padding(.horizontal, CCTheme.space5)
    }

    private var filterPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: CCTheme.space2) {
                ForEach(GoalFilter.allCases, id: \.self) { option in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            filter = option
                        }
                    } label: {
                        Text(option.rawValue)
                            .font(.ccSubhead.weight(filter == option ? .semibold : .regular))
                            .foregroundStyle(filter == option ? .white : CCTheme.ink)
                            .padding(.horizontal, CCTheme.space5)
                            .padding(.vertical, CCTheme.space3)
                            .background(filter == option ? CCTheme.navy : CCTheme.fog)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, CCTheme.space5)
        }
    }

    private var goalsList: some View {
        VStack(spacing: 0) {
            Divider()
            ForEach(Array(filteredGoals.enumerated()), id: \.element.id) { index, goal in
                Button {
                    selectedGoal = goal
                } label: {
                    GoalListRow(goal: goal)
                }
                .buttonStyle(.plain)
                if index < filteredGoals.count - 1 {
                    Divider().padding(.leading, CCTheme.space5)
                }
            }
            Divider()
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: CCTheme.space5) {
            InlineEmptyState(
                icon: "target",
                title: "No goals yet",
                subtitle: "Start tracking what matters most"
            )
            Button {
                showCreateGoal = true
            } label: {
                Text("Create a goal")
            }
            .buttonStyle(CCPrimaryButtonStyle())
        }
        .padding(.horizontal, CCTheme.space5)
    }
}
