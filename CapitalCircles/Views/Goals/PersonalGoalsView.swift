import SwiftUI

/// Shows the user's personal (non-shared) goals in a focused view.
/// Accessed from the "For you" section on the home hub.
struct PersonalGoalsView: View {
    @Environment(AppStateManager.self) private var state
    @Environment(\.dismiss) private var dismiss
    @State private var showCreateGoal = false
    @State private var selectedGoal: Goal?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CCTheme.space7) {
                header

                if state.personalGoals.isEmpty {
                    emptyState
                } else {
                    goalsList
                }
            }
            .padding(.vertical, CCTheme.space5)
            .padding(.bottom, CCTheme.space8)
        }
        .background(CCTheme.canvas)
        .navigationTitle("Personal goals")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(CCTheme.ink)
                }
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
            CreateGoalView(defaultCircleId: nil)
        }
        .sheet(item: $selectedGoal) { goal in
            GoalDetailView(goal: goal)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: CCTheme.space3) {
            Text("JUST FOR YOU")
                .font(.ccCaption)
                .foregroundStyle(CCTheme.slate)
                .tracking(0.5)
            let totalSaved = state.personalGoals.reduce(0.0) { $0 + $1.currentAmount }
            Text("$\(Int(totalSaved).formatted())")
                .font(.ccAmountLarge)
                .foregroundStyle(CCTheme.ink)
                .monospacedDigit()
            Text("Saved across \(state.personalGoals.count) personal \(state.personalGoals.count == 1 ? "goal" : "goals")")
                .font(.ccSubhead)
                .foregroundStyle(CCTheme.slate)
        }
        .padding(.horizontal, CCTheme.space5)
    }

    private var goalsList: some View {
        VStack(spacing: 0) {
            Divider()
            ForEach(Array(state.personalGoals.enumerated()), id: \.element.id) { index, goal in
                Button {
                    selectedGoal = goal
                } label: {
                    GoalListRow(goal: goal)
                }
                .buttonStyle(.plain)
                if index < state.personalGoals.count - 1 {
                    Divider().padding(.leading, CCTheme.space5)
                }
            }
            Divider()
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: CCTheme.space4) {
            Text("Start saving for something you care about")
                .font(.ccTitle)
                .foregroundStyle(CCTheme.ink)
            Text("Personal goals are private. Only you can see them. Use them to track savings that are just yours.")
                .font(.ccBody)
                .foregroundStyle(CCTheme.slate)
                .lineSpacing(2)
            Button {
                showCreateGoal = true
            } label: {
                Text("Create your first goal")
            }
            .buttonStyle(CCPrimaryButtonStyle())
            .padding(.top, CCTheme.space3)
        }
        .padding(.horizontal, CCTheme.space5)
    }
}
