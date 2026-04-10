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
                VStack(spacing: CCTheme.paddingLarge) {
                    circleHeader(circle)
                    statsRow(circle)
                    goalsSection(circle)
                    membersSection(circle)
                }
                .padding(.horizontal, CCTheme.paddingMedium)
                .padding(.bottom, CCTheme.paddingLarge)
            }
        }
        .background(CCTheme.backgroundPrimary)
        .navigationTitle(circle?.name ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showCreateGoal = true
                    } label: {
                        Label("Create goal", systemImage: "target")
                    }
                    Button {
                        showAddMember = true
                    } label: {
                        Label("Add member", systemImage: "person.badge.plus")
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(CCTheme.primaryBlue)
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

    private func circleHeader(_ circle: Circle) -> some View {
        VStack(spacing: 12) {
            Image(systemName: circle.iconName)
                .font(.system(size: 40))
                .foregroundStyle(.white)
                .frame(width: 90, height: 90)
                .background(
                    LinearGradient(
                        colors: [CCTheme.primaryBlue, CCTheme.accentBlue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 22))

            Text(circle.type.rawValue)
                .font(.caption.bold())
                .foregroundStyle(CCTheme.primaryBlue)
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(CCTheme.lightBlue)
                .clipShape(Capsule())
        }
        .padding(.top, CCTheme.paddingMedium)
    }

    private func statsRow(_ circle: Circle) -> some View {
        HStack(spacing: 12) {
            StatCard(
                title: "Members",
                value: "\(circle.memberCount)",
                subtitle: circle.type == .family ? "Family" : "People",
                icon: "person.fill",
                color: CCTheme.primaryBlue
            )
            StatCard(
                title: "Goals",
                value: "\(circle.goals.count)",
                subtitle: "\(Int(circle.totalGoalProgress * 100))% avg",
                icon: "target",
                color: CCTheme.successGreen
            )
        }
    }

    private func goalsSection(_ circle: Circle) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Shared goals")
                    .font(.headline)
                    .foregroundStyle(CCTheme.textPrimary)
                Spacer()
                Button {
                    showCreateGoal = true
                } label: {
                    Label("Add", systemImage: "plus")
                        .font(.caption.bold())
                        .foregroundStyle(CCTheme.accentBlue)
                }
            }

            if circle.goals.isEmpty {
                EmptyStateCard(
                    icon: "target",
                    title: "No shared goals yet",
                    message: "Create a goal for your circle to work toward together",
                    actionLabel: "Create goal",
                    action: { showCreateGoal = true }
                )
            } else {
                ForEach(circle.goals) { goal in
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

    private func membersSection(_ circle: Circle) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Members")
                    .font(.headline)
                    .foregroundStyle(CCTheme.textPrimary)
                Spacer()
                Button {
                    showAddMember = true
                } label: {
                    Label("Invite", systemImage: "person.badge.plus")
                        .font(.caption.bold())
                        .foregroundStyle(CCTheme.accentBlue)
                }
            }

            VStack(spacing: 0) {
                ForEach(circle.members) { member in
                    Button {
                        selectedMember = member
                    } label: {
                        MemberRow(member: member)
                    }
                    .buttonStyle(.plain)
                    if member.id != circle.members.last?.id {
                        Divider().padding(.leading, 56)
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

// MARK: - Member Row

struct MemberRow: View {
    let member: CircleMember

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: member.user.avatarIcon)
                .font(.title2)
                .foregroundStyle(CCTheme.primaryBlue)
                .frame(width: 40, height: 40)
                .background(CCTheme.lightBlue)
                .clipShape(SwiftUI.Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(member.user.name)
                    .font(.subheadline.bold())
                    .foregroundStyle(CCTheme.textPrimary)
                Text(member.role.rawValue)
                    .font(.caption)
                    .foregroundStyle(CCTheme.textSecondary)
            }

            Spacer()

            Text(member.visibilityLevel.rawValue)
                .font(.caption2.bold())
                .foregroundStyle(CCTheme.accentBlue)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(CCTheme.lightBlue)
                .clipShape(Capsule())
        }
        .padding(.vertical, 10)
    }
}
