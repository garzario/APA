import SwiftUI

struct CircleDetailView: View {
    @Environment(AppStateManager.self) private var state
    let circleId: UUID

    @State private var showAddMember = false
    @State private var showCreateGoal = false
    @State private var selectedGoal: Goal?
    @State private var selectedMember: CircleMember?

    private var circle: Circle? {
        state.circles.first(where: { $0.id == circleId })
    }

    var body: some View {
        ScrollView {
            if let circle {
                VStack(alignment: .leading, spacing: CCTheme.space7) {
                    header(circle)
                    sharedGoalsSection(circle)
                    membersSection(circle)
                }
                .padding(.vertical, CCTheme.space5)
                .padding(.bottom, CCTheme.space8)
            }
        }
        .background(CCTheme.canvas)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showCreateGoal = true
                    } label: {
                        Label("New goal", systemImage: "target")
                    }
                    Button {
                        showAddMember = true
                    } label: {
                        Label("Add member", systemImage: "person.badge.plus")
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(CCTheme.ink)
                }
            }
        }
        .sheet(isPresented: $showAddMember) {
            AddMemberView(circleId: circleId)
        }
        .sheet(isPresented: $showCreateGoal) {
            CreateGoalView()
        }
        .sheet(item: $selectedGoal) { goal in
            GoalDetailView(goal: goal)
        }
        .sheet(item: $selectedMember) { member in
            MemberDetailView(member: member, circleId: circleId)
        }
    }

    private func header(_ circle: Circle) -> some View {
        VStack(alignment: .leading, spacing: CCTheme.space4) {
            Text(circle.type.rawValue.uppercased())
                .font(.ccCaption)
                .foregroundStyle(CCTheme.slate)
                .tracking(0.5)

            Text(circle.name)
                .font(.ccLargeTitle)
                .foregroundStyle(CCTheme.ink)

            HStack(spacing: CCTheme.space6) {
                statBlock(value: "\(circle.memberCount)", label: "Members")
                statBlock(value: "\(circle.goals.count)", label: "Goals")
                statBlock(value: "\(Int(circle.totalGoalProgress * 100))%", label: "Progress")
            }
        }
        .padding(.horizontal, CCTheme.space5)
    }

    private func statBlock(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.ccAmount)
                .foregroundStyle(CCTheme.ink)
                .monospacedDigit()
            Text(label.uppercased())
                .font(.ccCaption)
                .foregroundStyle(CCTheme.slate)
                .tracking(0.5)
        }
    }

    private func sharedGoalsSection(_ circle: Circle) -> some View {
        CCSection("Shared goals", trailing: AnyView(
            Button {
                showCreateGoal = true
            } label: {
                Text("Add")
                    .font(.ccSubhead)
                    .foregroundStyle(CCTheme.navy)
            }
        )) {
            if circle.goals.isEmpty {
                InlineEmptyState(
                    icon: "target",
                    title: "No shared goals",
                    subtitle: "Create the first goal for this circle"
                )
                .padding(.horizontal, CCTheme.space5)
            } else {
                VStack(spacing: 0) {
                    Divider()
                    ForEach(Array(circle.goals.enumerated()), id: \.element.id) { index, goal in
                        Button {
                            selectedGoal = goal
                        } label: {
                            GoalListRow(goal: goal)
                        }
                        .buttonStyle(.plain)
                        if index < circle.goals.count - 1 {
                            Divider().padding(.leading, CCTheme.space5)
                        }
                    }
                    Divider()
                }
            }
        }
    }

    private func membersSection(_ circle: Circle) -> some View {
        CCSection("Members", trailing: AnyView(
            Button {
                showAddMember = true
            } label: {
                Text("Invite")
                    .font(.ccSubhead)
                    .foregroundStyle(CCTheme.navy)
            }
        )) {
            VStack(spacing: 0) {
                Divider()
                ForEach(Array(circle.members.enumerated()), id: \.element.id) { index, member in
                    Button {
                        selectedMember = member
                    } label: {
                        MemberRow(member: member, circleType: circle.type)
                    }
                    .buttonStyle(.plain)
                    if index < circle.members.count - 1 {
                        Divider().padding(.leading, 56)
                    }
                }
                Divider()
            }
        }
    }
}

// MARK: - Member Row

struct MemberRow: View {
    let member: CircleMember
    let circleType: CircleType

    var body: some View {
        HStack(spacing: CCTheme.space4) {
            CCAvatar(user: member.user, size: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(member.user.name)
                    .font(.ccBody)
                    .foregroundStyle(CCTheme.ink)
                Text(member.role.label(for: circleType))
                    .font(.ccFootnote)
                    .foregroundStyle(CCTheme.slate)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(CCTheme.mist)
        }
        .padding(.horizontal, CCTheme.space5)
        .padding(.vertical, CCTheme.space4)
        .contentShape(Rectangle())
    }
}
