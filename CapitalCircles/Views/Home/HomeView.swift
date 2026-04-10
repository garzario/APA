import SwiftUI

/// The Hub: a shared financial wellness view for the active circle.
/// Focus is on caring for the circle's finances together. Goals are one
/// tool among many, not the main event.
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

    private var currentMember: CircleMember? {
        activeCircle?.members.first(where: { $0.user.id == state.currentUser.id })
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: CCTheme.space7) {
                    if let activeCircle {
                        wellnessHeader(activeCircle)
                        membersGrid(activeCircle)
                        familyFinancesSection(activeCircle)
                        if !activeCircle.goals.isEmpty || !state.personalGoals.isEmpty {
                            goalsSection(activeCircle)
                        } else {
                            goalsPromoCard(activeCircle)
                        }
                        quickActionsSection
                        recentActivityInCircle(activeCircle)
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

    // MARK: - Wellness Header

    private func wellnessHeader(_ circle: Circle) -> some View {
        VStack(alignment: .leading, spacing: CCTheme.space5) {
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

            // Combined family spending this month
            VStack(alignment: .leading, spacing: CCTheme.space2) {
                Text("\(circleSpendingLabel(circle)) THIS MONTH")
                    .font(.ccCaption)
                    .foregroundStyle(.white.opacity(0.7))
                    .tracking(0.5)
                Text("$\(Int(combinedMonthlySpending).formatted())")
                    .font(.ccAmountLarge)
                    .foregroundStyle(.white)
                    .monospacedDigit()
                HStack(spacing: 4) {
                    Image(systemName: "arrow.down.right")
                        .font(.system(size: 11, weight: .semibold))
                    Text("Trending steady")
                        .font(.ccFootnote)
                }
                .foregroundStyle(.white.opacity(0.85))
            }
        }
        .padding(CCTheme.space6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ZStack {
                CCTheme.navy
                // Capital One red swoosh in corner
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

    private func circleSpendingLabel(_ circle: Circle) -> String {
        switch circle.type {
        case .family: return "FAMILY"
        case .roommates: return "HOUSEHOLD"
        case .friends: return "TOGETHER"
        case .couple: return "WE"
        }
    }

    private var combinedMonthlySpending: Double {
        // Current month statement for the current user, extended for demo.
        // In production this would sum across all circle members who opted in.
        state.currentStatement?.totalSpent ?? 0
    }

    // MARK: - Members Grid

    private func membersGrid(_ circle: Circle) -> some View {
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
                            memberTile(member, in: circle)
                        }
                        .buttonStyle(.plain)
                    }

                    Button {
                        showAddMember = true
                    } label: {
                        VStack(spacing: CCTheme.space2) {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundStyle(CCTheme.slate)
                                .frame(width: 64, height: 64)
                                .overlay {
                                    SwiftUI.Circle()
                                        .strokeBorder(CCTheme.hairline, style: StrokeStyle(lineWidth: 1.5, dash: [4]))
                                }
                            Text("Invite")
                                .font(.ccFootnote)
                                .foregroundStyle(CCTheme.slate)
                        }
                        .frame(width: 80)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, CCTheme.space5)
            }
        }
    }

    private func memberTile(_ member: CircleMember, in circle: Circle) -> some View {
        VStack(spacing: CCTheme.space2) {
            CCAvatar(user: member.user, size: 64)
            VStack(spacing: 2) {
                Text(member.user.name.components(separatedBy: " ").first ?? "")
                    .font(.ccFootnote.bold())
                    .foregroundStyle(CCTheme.ink)
                    .lineLimit(1)
                Text(member.role.label(for: circle.type))
                    .font(.ccCaption)
                    .foregroundStyle(CCTheme.slate)
            }
        }
        .frame(width: 80)
    }

    // MARK: - Family Finances

    private func familyFinancesSection(_ circle: Circle) -> some View {
        CCSection("Financial wellness") {
            VStack(spacing: 0) {
                Divider()
                ForEach(Array(circle.members.enumerated()), id: \.element.id) { index, member in
                    memberFinanceRow(member, in: circle)
                    if index < circle.members.count - 1 {
                        Divider().padding(.leading, CCTheme.space5 + 44)
                    }
                }
                Divider()
            }
        }
    }

    private func memberFinanceRow(_ member: CircleMember, in circle: Circle) -> some View {
        let canSeeDetails = canCurrentUserSeeSpending(of: member, in: circle)
        let isMe = member.user.id == state.currentUser.id

        return Button {
            selectedMember = member
        } label: {
            HStack(spacing: CCTheme.space4) {
                CCAvatar(user: member.user, size: 40)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(member.user.name.components(separatedBy: " ").first ?? "")
                            .font(.ccBody)
                            .foregroundStyle(CCTheme.ink)
                        if isMe {
                            Text("You")
                                .font(.ccCaption)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(CCTheme.navy)
                                .clipShape(Capsule())
                        }
                    }
                    Text(canSeeDetails || isMe ? financeStatus(for: member) : "Private")
                        .font(.ccFootnote)
                        .foregroundStyle(CCTheme.slate)
                }

                Spacer()

                if canSeeDetails || isMe {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("$\(Int(monthlySpending(for: member)).formatted())")
                            .font(.ccBody)
                            .foregroundStyle(CCTheme.ink)
                            .monospacedDigit()
                        Text("this month")
                            .font(.ccCaption)
                            .foregroundStyle(CCTheme.slate)
                    }
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(CCTheme.mist)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(CCTheme.mist)
            }
            .padding(.horizontal, CCTheme.space5)
            .padding(.vertical, CCTheme.space4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func canCurrentUserSeeSpending(of member: CircleMember, in circle: Circle) -> Bool {
        guard let currentMember else { return false }
        if member.user.id == state.currentUser.id { return true }
        return currentMember.role.canViewSpending(of: member.role, in: circle.type)
    }

    private func financeStatus(for member: CircleMember) -> String {
        // Demo values — in production these would be real
        if member.user.id == state.currentUser.id {
            return "On track, 12% under March"
        }
        if member.role == .junior {
            return "Within allowance"
        }
        return "On track"
    }

    private func monthlySpending(for member: CircleMember) -> Double {
        // Demo values. In production this aggregates per member.
        if member.user.id == state.currentUser.id {
            return state.currentStatement?.totalSpent ?? 0
        }
        if member.role == .junior { return 320 }
        return Double(Int.random(in: 3500...6800))
    }

    // MARK: - Goals (only shown when they exist)

    private func goalsSection(_ circle: Circle) -> some View {
        let hasShared = !circle.goals.isEmpty
        let hasPersonal = !state.personalGoals.isEmpty

        return CCSection("Goals", trailing: AnyView(
            Button {
                showCreateGoal = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .semibold))
                    Text("New")
                        .font(.ccSubhead)
                }
                .foregroundStyle(CCTheme.navy)
            }
        )) {
            VStack(spacing: 0) {
                Divider()
                if hasShared {
                    ForEach(Array(circle.goals.enumerated()), id: \.element.id) { index, goal in
                        Button {
                            selectedGoal = goal
                        } label: {
                            GoalListRow(goal: goal)
                        }
                        .buttonStyle(.plain)
                        if index < circle.goals.count - 1 || hasPersonal {
                            Divider().padding(.leading, CCTheme.space5)
                        }
                    }
                }
                if hasPersonal {
                    ForEach(Array(state.personalGoals.prefix(2).enumerated()), id: \.element.id) { index, goal in
                        Button {
                            selectedGoal = goal
                        } label: {
                            GoalListRow(goal: goal)
                        }
                        .buttonStyle(.plain)
                        if index < min(state.personalGoals.count, 2) - 1 {
                            Divider().padding(.leading, CCTheme.space5)
                        }
                    }
                }
                Divider()
            }
        }
    }

    // MARK: - Goals Promo (when no goals exist)

    private func goalsPromoCard(_ circle: Circle) -> some View {
        VStack(alignment: .leading, spacing: CCTheme.space3) {
            HStack(spacing: CCTheme.space2) {
                Image(systemName: "target")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(CCTheme.navy)
                Text("GOALS")
                    .font(.ccCaption)
                    .foregroundStyle(CCTheme.slate)
                    .tracking(0.5)
            }
            Text("Saving for something together?")
                .font(.ccTitle)
                .foregroundStyle(CCTheme.ink)
            Text("Goals are optional. Create one when your circle wants to work toward something specific, like a trip or an emergency fund. Your hub stays useful either way.")
                .font(.ccFootnote)
                .foregroundStyle(CCTheme.slate)
                .lineSpacing(3)
            Button {
                showCreateGoal = true
            } label: {
                Text("Create a goal")
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
        .clipShape(RoundedRectangle(cornerRadius: CCTheme.radiusLarge))
        .padding(.horizontal, CCTheme.space5)
    }

    // MARK: - Quick Actions

    private var quickActionsSection: some View {
        CCSection("For you") {
            VStack(spacing: 0) {
                Divider()
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
                Divider().padding(.leading, 56)
                Button {
                    showPersonalGoals = true
                } label: {
                    QuickLinkRow(
                        icon: "target",
                        title: "Personal goals",
                        subtitle: state.personalGoals.isEmpty ? "Private goals just for you" : "\(state.personalGoals.count) active",
                        badge: nil
                    )
                }
                .buttonStyle(.plain)
                Divider()
            }
        }
    }

    // MARK: - Recent Activity

    private func recentActivityInCircle(_ circle: Circle) -> some View {
        CCSection("Activity") {
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
                Text("Create your first circle to start looking after finances together.")
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
                        .fill(CCTheme.navy)
                        .frame(width: geo.size.width * goal.progressPercentage, height: 4)
                }
            }
            .frame(height: 4)
        }
        .padding(.horizontal, CCTheme.space5)
        .padding(.vertical, CCTheme.space4)
        .contentShape(Rectangle())
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
