import SwiftUI

/// The Family Hub: the main experience of Capital Circles.
/// This is where users see their primary circle, shared goals, and personal activity.
struct HomeView: View {
    @Environment(AppStateManager.self) private var state
    @State private var showNotifications = false
    @State private var selectedTransaction: Transaction?
    @State private var selectedGoal: Goal?

    /// The primary circle is the first family-type circle, or the first circle available.
    private var primaryCircle: Circle? {
        state.circles.first(where: { $0.type == .family }) ?? state.circles.first
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: CCTheme.space7) {
                    greetingHeader
                    if let primaryCircle {
                        hubSection(primaryCircle)
                        sharedGoalsSection(primaryCircle)
                    }
                    personalSection
                    recentActivitySection
                    otherCirclesSection
                }
                .padding(.vertical, CCTheme.space5)
            }
            .background(CCTheme.canvas)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Capital Circles")
                        .font(.ccHeadline)
                        .foregroundStyle(CCTheme.ink)
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
                                    .frame(width: 7, height: 7)
                                    .offset(x: 4, y: -2)
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showNotifications) { NotificationsView() }
            .sheet(item: $selectedTransaction) { TransactionDetailView(transaction: $0) }
            .sheet(item: $selectedGoal) { GoalDetailView(goal: $0) }
            .navigationDestination(for: UUID.self) { id in
                CircleDetailView(circleId: id)
            }
        }
    }

    // MARK: - Greeting

    private var greetingHeader: some View {
        VStack(alignment: .leading, spacing: CCTheme.space2) {
            Text(greeting)
                .font(.ccCaption)
                .foregroundStyle(CCTheme.slate)
                .textCase(.uppercase)
                .tracking(0.5)
            Text(state.currentUser.name.components(separatedBy: " ").first ?? "")
                .font(.ccLargeTitle)
                .foregroundStyle(CCTheme.ink)
        }
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

    // MARK: - Family Hub

    private func hubSection(_ circle: Circle) -> some View {
        NavigationLink(value: circle.id) {
            VStack(alignment: .leading, spacing: CCTheme.space5) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: CCTheme.space1) {
                        Text(circle.type.rawValue.uppercased())
                            .font(.ccCaption)
                            .foregroundStyle(.white.opacity(0.7))
                            .tracking(1)
                        Text(circle.name)
                            .font(.ccTitle)
                            .foregroundStyle(.white)
                    }
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white.opacity(0.85))
                }

                // Member avatars row
                HStack(spacing: -10) {
                    ForEach(circle.members.prefix(4)) { member in
                        Image(systemName: member.user.avatarIcon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(CCTheme.navy.opacity(0.9))
                            .clipShape(SwiftUI.Circle())
                            .overlay {
                                SwiftUI.Circle().stroke(.white, lineWidth: 2)
                            }
                    }
                    if circle.members.count > 4 {
                        Text("+\(circle.members.count - 4)")
                            .font(.ccFootnote.bold())
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(CCTheme.navy.opacity(0.9))
                            .clipShape(SwiftUI.Circle())
                            .overlay {
                                SwiftUI.Circle().stroke(.white, lineWidth: 2)
                            }
                    }
                    Spacer()
                    Text("\(circle.members.count) members")
                        .font(.ccFootnote)
                        .foregroundStyle(.white.opacity(0.85))
                }

                Divider().background(.white.opacity(0.2))

                HStack(spacing: CCTheme.space6) {
                    hubStat(label: "Shared goals", value: "\(circle.goals.count)")
                    hubStat(label: "Progress", value: "\(Int(circle.totalGoalProgress * 100))%")
                    hubStat(label: "Saved together", value: "$\(shortAmount(circle.goals.reduce(0) { $0 + $1.currentAmount }))")
                }
            }
            .padding(CCTheme.space6)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(CCTheme.navy)
            .clipShape(RoundedRectangle(cornerRadius: CCTheme.radiusLarge))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, CCTheme.space5)
    }

    private func hubStat(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.ccHeadline)
                .foregroundStyle(.white)
            Text(label)
                .font(.ccCaption)
                .foregroundStyle(.white.opacity(0.7))
        }
    }

    // MARK: - Shared Goals (from primary circle)

    private func sharedGoalsSection(_ circle: Circle) -> some View {
        CCSection("Family goals", trailing: AnyView(
            NavigationLink(value: circle.id) {
                Text("See all")
                    .font(.ccSubhead)
                    .foregroundStyle(CCTheme.navy)
            }
        )) {
            if circle.goals.isEmpty {
                InlineEmptyState(
                    icon: "target",
                    title: "No family goals yet",
                    subtitle: "Tap the circle above to create one"
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
                .background(CCTheme.canvas)
            }
        }
    }

    // MARK: - Personal

    private var personalSection: some View {
        let personal = state.personalGoals
        return CCSection("For you") {
            VStack(spacing: 0) {
                if let first = personal.first {
                    Divider()
                    Button {
                        selectedGoal = first
                    } label: {
                        GoalListRow(goal: first)
                    }
                    .buttonStyle(.plain)
                }
                Divider()
                NavigationLink(destination: CardSelectorView()) {
                    QuickLinkRow(
                        icon: "creditcard",
                        title: "Card optimizer",
                        subtitle: "Best card per purchase"
                    )
                }
                Divider().padding(.leading, 56)
                NavigationLink(destination: StatementView()) {
                    QuickLinkRow(
                        icon: "chart.bar",
                        title: "This month's insights",
                        subtitle: "AI summary of your spending"
                    )
                }
                Divider()
            }
            .background(CCTheme.canvas)
        }
    }

    // MARK: - Recent Activity

    private var recentActivitySection: some View {
        CCSection("Recent activity") {
            VStack(spacing: 0) {
                Divider()
                ForEach(Array(state.transactions.prefix(5).enumerated()), id: \.element.id) { index, transaction in
                    Button {
                        selectedTransaction = transaction
                    } label: {
                        TransactionRow(transaction: transaction)
                    }
                    .buttonStyle(.plain)
                    if index < 4 {
                        Divider().padding(.leading, 56)
                    }
                }
                Divider()
            }
            .background(CCTheme.canvas)
        }
    }

    // MARK: - Other Circles

    @ViewBuilder
    private var otherCirclesSection: some View {
        let otherCircles = state.circles.filter { $0.id != primaryCircle?.id }
        if !otherCircles.isEmpty {
            CCSection("Other circles") {
                VStack(spacing: 0) {
                    Divider()
                    ForEach(Array(otherCircles.enumerated()), id: \.element.id) { index, circle in
                        NavigationLink(value: circle.id) {
                            CircleListRow(circle: circle)
                        }
                        .buttonStyle(.plain)
                        if index < otherCircles.count - 1 {
                            Divider().padding(.leading, 56)
                        }
                    }
                    Divider()
                }
                .background(CCTheme.canvas)
            }
        }
    }

    // MARK: - Helpers

    private func shortAmount(_ value: Double) -> String {
        if value >= 1000 {
            return String(format: "%.0fK", value / 1000)
        }
        return String(Int(value))
    }
}

// MARK: - Goal List Row

struct GoalListRow: View {
    let goal: Goal

    var body: some View {
        VStack(alignment: .leading, spacing: CCTheme.space3) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(goal.title)
                        .font(.ccHeadline)
                        .foregroundStyle(CCTheme.ink)
                    Text("$\(Int(goal.currentAmount).formatted()) of $\(Int(goal.targetAmount).formatted())")
                        .font(.ccFootnote)
                        .foregroundStyle(CCTheme.slate)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(goal.progressPercentage * 100))%")
                        .font(.ccHeadline)
                        .foregroundStyle(CCTheme.ink)
                        .monospacedDigit()
                    if goal.isShared {
                        Text("Shared")
                            .font(.ccCaption)
                            .foregroundStyle(CCTheme.slate)
                    }
                }
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
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(CCTheme.mist)
        }
        .padding(.horizontal, CCTheme.space5)
        .padding(.vertical, CCTheme.space4)
        .contentShape(Rectangle())
    }
}

// MARK: - Circle List Row

struct CircleListRow: View {
    let circle: Circle

    var body: some View {
        HStack(spacing: CCTheme.space4) {
            Image(systemName: circle.iconName)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(CCTheme.navy)
                .frame(width: 36, height: 36)
                .background(CCTheme.fog)
                .clipShape(SwiftUI.Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(circle.name)
                    .font(.ccBody)
                    .foregroundStyle(CCTheme.ink)
                Text("\(circle.memberCount) members • \(circle.goals.count) goals")
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

// MARK: - Inline Empty State

struct InlineEmptyState: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: CCTheme.space4) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .regular))
                .foregroundStyle(CCTheme.mist)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.ccBody)
                    .foregroundStyle(CCTheme.ink)
                Text(subtitle)
                    .font(.ccFootnote)
                    .foregroundStyle(CCTheme.slate)
            }
            Spacer()
        }
        .padding(CCTheme.space4)
        .background(CCTheme.fog)
        .clipShape(RoundedRectangle(cornerRadius: CCTheme.radiusMedium))
    }
}

#Preview {
    HomeView()
        .environment(AppStateManager.shared)
        .environment(AppState())
}
