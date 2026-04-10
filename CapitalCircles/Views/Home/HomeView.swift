import SwiftUI

/// The Hub: the main experience of Capital Circles.
/// Shows the currently active circle with members, shared goals, and activity.
/// Everything is accessible from here through taps — no need for dedicated tabs
/// for Circles or Goals.
struct HomeView: View {
    @Environment(AppStateManager.self) private var state
    @State private var activeCircleId: UUID?
    @State private var showCircleSwitcher = false
    @State private var showNotifications = false
    @State private var showCreateGoal = false
    @State private var showAddMember = false
    @State private var selectedGoal: Goal?
    @State private var selectedMember: CircleMember?
    @State private var showCardOptimizer = false
    @State private var showPersonalGoals = false

    private var activeCircle: Circle? {
        if let activeCircleId {
            return state.circles.first(where: { $0.id == activeCircleId })
        }
        return state.circles.first(where: { $0.type == .family }) ?? state.circles.first
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: CCTheme.space7) {
                    if let activeCircle {
                        heroSection(activeCircle)
                        membersSection(activeCircle)
                        sharedGoalsSection(activeCircle)
                        personalSection
                        activitySection
                    } else {
                        emptyState
                    }
                }
                .padding(.vertical, CCTheme.space5)
                .padding(.bottom, CCTheme.space8)
            }
            .background(CCTheme.canvas)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showCircleSwitcher = true
                    } label: {
                        HStack(spacing: 6) {
                            Text(activeCircle?.name ?? "Your hub")
                                .font(.ccHeadline)
                                .foregroundStyle(CCTheme.ink)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(CCTheme.slate)
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showNotifications = true
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "bell")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundStyle(CCTheme.ink)
                            if state.unreadNotificationCount > 0 {
                                SwiftUI.Circle()
                                    .fill(CCTheme.red)
                                    .frame(width: 8, height: 8)
                                    .overlay(SwiftUI.Circle().stroke(CCTheme.canvas, lineWidth: 1.5))
                                    .offset(x: 4, y: -2)
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showCircleSwitcher) {
                CircleSwitcherSheet(activeCircleId: $activeCircleId)
                    .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $showNotifications) {
                NotificationsView()
            }
            .sheet(isPresented: $showCreateGoal) {
                CreateGoalView(defaultCircleId: activeCircle?.id)
            }
            .sheet(isPresented: $showAddMember) {
                if let activeCircle {
                    AddMemberView(circleId: activeCircle.id)
                }
            }
            .sheet(item: $selectedGoal) { goal in
                GoalDetailView(goal: goal)
            }
            .sheet(item: $selectedMember) { member in
                if let activeCircle {
                    MemberDetailView(member: member, circleId: activeCircle.id)
                }
            }
            .sheet(isPresented: $showCardOptimizer) {
                NavigationStack { CardSelectorView() }
            }
            .sheet(isPresented: $showPersonalGoals) {
                NavigationStack { PersonalGoalsView() }
            }
        }
    }

    // MARK: - Hero

    private func heroSection(_ circle: Circle) -> some View {
        VStack(alignment: .leading, spacing: CCTheme.space6) {
            VStack(alignment: .leading, spacing: CCTheme.space2) {
                Text(greeting.uppercased())
                    .font(.ccCaption)
                    .foregroundStyle(.white.opacity(0.7))
                    .tracking(0.5)
                Text(state.currentUser.name.components(separatedBy: " ").first ?? "")
                    .font(.ccLargeTitle)
                    .foregroundStyle(.white)
            }

            Divider().background(.white.opacity(0.15))

            HStack(spacing: CCTheme.space6) {
                heroStat(value: "\(circle.memberCount)", label: "Members")
                heroStat(value: "\(circle.goals.count)", label: "Goals")
                heroStat(value: "\(Int(circle.totalGoalProgress * 100))%", label: "Progress")
            }
        }
        .padding(CCTheme.space6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ZStack {
                CCTheme.navy
                // Subtle Capital One red swoosh accent in corner
                GeometryReader { geo in
                    Path { path in
                        path.move(to: CGPoint(x: geo.size.width * 0.5, y: geo.size.height + 20))
                        path.addQuadCurve(
                            to: CGPoint(x: geo.size.width + 20, y: geo.size.height * 0.4),
                            control: CGPoint(x: geo.size.width, y: geo.size.height + 40)
                        )
                        path.addLine(to: CGPoint(x: geo.size.width + 20, y: geo.size.height + 20))
                        path.closeSubpath()
                    }
                    .fill(CCTheme.red.opacity(0.9))
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: CCTheme.radiusLarge))
        .padding(.horizontal, CCTheme.space5)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<18: return "Good afternoon"
        default: return "Good evening"
        }
    }

    private func heroStat(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.ccTitle)
                .foregroundStyle(.white)
                .monospacedDigit()
            Text(label)
                .font(.ccCaption)
                .foregroundStyle(.white.opacity(0.75))
        }
    }

    // MARK: - Members

    private func membersSection(_ circle: Circle) -> some View {
        CCSection(circle.type.rawValue, trailing: AnyView(
            Button {
                showAddMember = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .semibold))
                    Text("Add")
                        .font(.ccSubhead)
                }
                .foregroundStyle(CCTheme.navy)
            }
        )) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: CCTheme.space4) {
                    ForEach(circle.members) { member in
                        Button {
                            selectedMember = member
                        } label: {
                            VStack(spacing: CCTheme.space2) {
                                CCAvatar(user: member.user, size: 56)
                                VStack(spacing: 2) {
                                    Text(member.user.name.components(separatedBy: " ").first ?? "")
                                        .font(.ccFootnote)
                                        .foregroundStyle(CCTheme.ink)
                                    Text(member.role.rawValue)
                                        .font(.ccCaption)
                                        .foregroundStyle(CCTheme.slate)
                                }
                            }
                            .frame(width: 70)
                        }
                        .buttonStyle(.plain)
                    }

                    // Add member button
                    Button {
                        showAddMember = true
                    } label: {
                        VStack(spacing: CCTheme.space2) {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundStyle(CCTheme.slate)
                                .frame(width: 56, height: 56)
                                .overlay {
                                    SwiftUI.Circle()
                                        .strokeBorder(CCTheme.hairline, style: StrokeStyle(lineWidth: 1.5, dash: [4]))
                                }
                            Text("Invite")
                                .font(.ccFootnote)
                                .foregroundStyle(CCTheme.slate)
                        }
                        .frame(width: 70)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, CCTheme.space5)
            }
        }
    }

    // MARK: - Shared Goals

    private func sharedGoalsSection(_ circle: Circle) -> some View {
        CCSection("Together we are saving for", trailing: AnyView(
            Button {
                showCreateGoal = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .semibold))
                    Text("New goal")
                        .font(.ccSubhead)
                }
                .foregroundStyle(CCTheme.navy)
            }
        )) {
            if circle.goals.isEmpty {
                emptyGoalCard
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

    private var emptyGoalCard: some View {
        VStack(alignment: .leading, spacing: CCTheme.space3) {
            Text("No shared goals yet")
                .font(.ccBody)
                .foregroundStyle(CCTheme.ink)
            Text("Create a goal that your circle can work toward together. Nobody shares their accounts, only the progress toward the goal.")
                .font(.ccFootnote)
                .foregroundStyle(CCTheme.slate)
                .lineSpacing(2)
            Button {
                showCreateGoal = true
            } label: {
                Text("Create first goal")
                    .font(.ccSubhead.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, CCTheme.space5)
                    .padding(.vertical, CCTheme.space3)
                    .background(CCTheme.navy)
                    .clipShape(Capsule())
            }
            .padding(.top, CCTheme.space2)
        }
        .padding(CCTheme.space5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CCTheme.cream)
        .clipShape(RoundedRectangle(cornerRadius: CCTheme.radiusMedium))
        .padding(.horizontal, CCTheme.space5)
    }

    // MARK: - Personal Section

    private var personalSection: some View {
        CCSection("For you") {
            VStack(spacing: 0) {
                Divider()
                Button {
                    showPersonalGoals = true
                } label: {
                    QuickLinkRow(
                        icon: "target",
                        title: "My personal goals",
                        subtitle: state.personalGoals.isEmpty ? "Track what matters to you" : "\(state.personalGoals.count) active",
                        badge: state.personalGoals.isEmpty ? nil : "\(Int(state.personalGoals.first?.progressPercentage ?? 0 * 100))%"
                    )
                }
                .buttonStyle(.plain)
                Divider().padding(.leading, 56)
                Button {
                    showCardOptimizer = true
                } label: {
                    QuickLinkRow(
                        icon: "creditcard",
                        title: "Card optimizer",
                        subtitle: "Best Capital One card per purchase",
                        badge: nil
                    )
                }
                .buttonStyle(.plain)
                Divider()
            }
        }
    }

    // MARK: - Activity

    private var activitySection: some View {
        CCSection("Recent activity") {
            if state.transactions.isEmpty {
                Text("No activity yet")
                    .font(.ccFootnote)
                    .foregroundStyle(CCTheme.slate)
                    .padding(.horizontal, CCTheme.space5)
            } else {
                VStack(spacing: 0) {
                    Divider()
                    ForEach(Array(state.transactions.prefix(4).enumerated()), id: \.element.id) { index, transaction in
                        TransactionRow(transaction: transaction)
                        if index < 3 {
                            Divider().padding(.leading, 56)
                        }
                    }
                    Divider()
                }
            }
        }
    }

    // MARK: - Empty state when no circles

    private var emptyState: some View {
        VStack(alignment: .center, spacing: CCTheme.space5) {
            Image(systemName: "person.2")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(CCTheme.mist)
                .padding(.top, CCTheme.space9)

            VStack(spacing: CCTheme.space2) {
                Text("Your hub is empty")
                    .font(.ccTitle)
                    .foregroundStyle(CCTheme.ink)
                Text("Create your first circle to start reaching goals with the people who matter.")
                    .font(.ccBody)
                    .foregroundStyle(CCTheme.slate)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, CCTheme.space6)
            }

            Button {
                showCircleSwitcher = true
            } label: {
                Text("Create a circle")
            }
            .buttonStyle(CCPrimaryButtonStyle())
            .padding(.horizontal, CCTheme.space5)
            .padding(.top, CCTheme.space4)
        }
    }
}

// MARK: - Goal List Row (reused across the app)

struct GoalListRow: View {
    let goal: Goal

    var body: some View {
        VStack(alignment: .leading, spacing: CCTheme.space3) {
            HStack(alignment: .top) {
                Image(systemName: goal.iconName)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(CCTheme.navy)
                    .frame(width: 32, height: 32)
                    .background(CCTheme.fog)
                    .clipShape(SwiftUI.Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(goal.title)
                        .font(.ccHeadline)
                        .foregroundStyle(CCTheme.ink)
                    Text("$\(Int(goal.currentAmount).formatted()) of $\(Int(goal.targetAmount).formatted())")
                        .font(.ccFootnote)
                        .foregroundStyle(CCTheme.slate)
                        .monospacedDigit()
                }

                Spacer()

                Text("\(Int(goal.progressPercentage * 100))%")
                    .font(.ccHeadline)
                    .foregroundStyle(CCTheme.ink)
                    .monospacedDigit()
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(CCTheme.hairline)
                        .frame(height: 4)
                    Capsule()
                        .fill(progressColor)
                        .frame(width: geo.size.width * goal.progressPercentage, height: 4)
                }
            }
            .frame(height: 4)
        }
        .padding(.horizontal, CCTheme.space5)
        .padding(.vertical, CCTheme.space4)
        .contentShape(Rectangle())
    }

    private var progressColor: Color {
        if goal.progressPercentage >= 1.0 { return CCTheme.positive }
        if goal.progressPercentage >= 0.75 { return CCTheme.navy }
        return CCTheme.navy
    }
}

// MARK: - Quick Link Row

struct QuickLinkRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let badge: String?

    var body: some View {
        HStack(spacing: CCTheme.space4) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .regular))
                .foregroundStyle(CCTheme.ink)
                .frame(width: 28, alignment: .center)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.ccBody)
                    .foregroundStyle(CCTheme.ink)
                Text(subtitle)
                    .font(.ccFootnote)
                    .foregroundStyle(CCTheme.slate)
            }
            Spacer()
            if let badge {
                Text(badge)
                    .font(.ccCaption)
                    .foregroundStyle(CCTheme.slate)
            }
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(CCTheme.mist)
        }
        .padding(.horizontal, CCTheme.space5)
        .padding(.vertical, CCTheme.space4)
        .contentShape(Rectangle())
    }
}

#Preview {
    HomeView()
        .environment(AppStateManager.shared)
        .environment(AppState())
}
