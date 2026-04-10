import Foundation
import SwiftUI

/// Central observable state manager for the app.
/// Loads data from the backend API on launch and writes all mutations back.
/// Keeps a local in-memory representation so the UI stays responsive while
/// network calls happen.
@Observable
final class AppStateManager {
    static let shared = AppStateManager()

    // MARK: - Current User

    var currentUser: User
    var allUsers: [User] = []

    // MARK: - Circles and Goals

    var circles: [Circle] = []
    var personalGoals: [Goal] = []

    // MARK: - Transactions and Cards

    var transactions: [Transaction] = []

    // MARK: - Smart Statements

    var statements: [SmartStatement] = []
    var selectedStatementId: UUID?
    var isLoadingStatement: Bool = false

    var currentStatement: SmartStatement? {
        get {
            if let id = selectedStatementId {
                return statements.first(where: { $0.id == id })
            }
            return statements.last
        }
        set {
            guard let newValue else { return }
            if let index = statements.firstIndex(where: { $0.id == newValue.id }) {
                statements[index] = newValue
            }
            selectedStatementId = newValue.id
        }
    }

    // MARK: - Notifications

    var notifications: [AppNotification] = []

    // MARK: - Sync state

    var isSyncing: Bool = false
    var lastSyncError: String?

    // MARK: - Init

    private init() {
        // Start empty. Real data loads from the backend after sign-in.
        // Statements (AI-generated insights) are the only pre-loaded content
        // so the Insights tab has something to show immediately.
        self.currentUser = User(
            id: UUID(),
            name: "",
            email: "",
            avatarIcon: "person.circle.fill",
            cards: [],
            transactions: [],
            joinedDate: Date()
        )
        self.allUsers = []
        self.circles = []
        self.personalGoals = []
        self.transactions = []
        self.statements = SeedData.generateStatements()
        self.selectedStatementId = self.statements.last?.id
        self.notifications = []
    }

    // MARK: - Auth / sync from backend

    /// Sign the user in by creating or fetching their backend profile.
    /// Called from onboarding once the user enters their name and email.
    func signIn(name: String, email: String) async {
        isSyncing = true
        defer { isSyncing = false }

        do {
            // Try to fetch existing user by email first
            let apiUser: APIUser
            do {
                apiUser = try await UserAPI.getByEmail(email)
            } catch {
                // Not found: create a new one
                apiUser = try await UserAPI.create(name: name, email: email)
            }

            // Build the user with generated mock cards and transactions
            var user = User(
                id: apiUser.id,
                name: apiUser.name,
                email: apiUser.email,
                avatarIcon: apiUser.avatarIcon,
                cards: [],
                transactions: [],
                joinedDate: apiUser.createdAt ?? Date()
            )
            user.cards = MockCardGenerator.generateCards(for: user)
            user.transactions = MockCardGenerator.generateTransactions(for: user, cards: user.cards)

            currentUser = user
            allUsers = [user]

            // Load their circles and goals from DB
            await refreshFromBackend()
        } catch {
            lastSyncError = error.localizedDescription
        }
    }

    /// Reload circles, members, and goals for the current user from the backend.
    func refreshFromBackend() async {
        do {
            let apiCircles = try await CircleAPI.list(forUser: currentUser.id)
            let apiGoals = try await GoalAPI.list(forUser: currentUser.id)

            var newCircles: [Circle] = []
            var userCache: [UUID: User] = [currentUser.id: currentUser]

            for api in apiCircles {
                // Fetch members for this circle
                let apiMembers = (try? await CircleAPI.members(circleId: api.id)) ?? []

                var members: [CircleMember] = []
                for apiMember in apiMembers {
                    // Build or reuse user
                    let user: User
                    if let cached = userCache[apiMember.userId] {
                        user = cached
                    } else {
                        var newUser = User(
                            id: apiMember.userId,
                            name: apiMember.name ?? "Unknown",
                            email: apiMember.email ?? "",
                            avatarIcon: apiMember.avatarIcon ?? "person.circle.fill",
                            cards: [],
                            transactions: [],
                            joinedDate: Date()
                        )
                        newUser.cards = MockCardGenerator.generateCards(for: newUser)
                        newUser.transactions = MockCardGenerator.generateTransactions(for: newUser, cards: newUser.cards)
                        userCache[apiMember.userId] = newUser
                        user = newUser
                    }

                    members.append(CircleMember(
                        id: apiMember.id,
                        user: user,
                        role: MemberRole(rawValue: apiMember.role.capitalized) ?? .member,
                        visibilityLevel: VisibilityLevel(rawValue: apiMember.visibility) ?? .goalsOnly,
                        joinedDate: Date()
                    ))
                }

                // Ensure current user is always in the member list
                if !members.contains(where: { $0.user.id == currentUser.id }) {
                    members.insert(CircleMember(
                        id: UUID(),
                        user: currentUser,
                        role: .admin,
                        visibilityLevel: .goalsOnly,
                        joinedDate: api.createdAt ?? Date()
                    ), at: 0)
                }

                let circleType = CircleType(rawValue: api.type.capitalized) ?? .family

                newCircles.append(Circle(
                    id: api.id,
                    name: api.name,
                    type: circleType,
                    iconName: api.iconName,
                    members: members,
                    goals: [],
                    createdAt: api.createdAt ?? Date()
                ))
            }

            // Update allUsers from cache
            allUsers = Array(userCache.values)

            // Assign goals to their circles from backend
            var personal: [Goal] = []
            for api in apiGoals {
                let goal = Goal(
                    id: api.id,
                    title: api.title,
                    iconName: api.iconName,
                    targetAmount: api.targetAmount,
                    currentAmount: api.currentAmount,
                    deadline: nil,
                    isShared: api.isShared,
                    circleId: api.circleId,
                    contributions: [],
                    createdAt: Date()
                )
                if let circleId = api.circleId,
                   let idx = newCircles.firstIndex(where: { $0.id == circleId }) {
                    newCircles[idx].goals.append(goal)
                } else {
                    personal.append(goal)
                }
            }

            circles = newCircles
            personalGoals = personal
        } catch {
            // Silent fallback — the app remains usable with whatever state is loaded
            print("Refresh from backend failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Circles

    func createCircle(name: String, type: CircleType, iconName: String) -> Circle {
        let newCircle = Circle(
            id: UUID(),
            name: name,
            type: type,
            iconName: iconName,
            members: [
                CircleMember(
                    id: UUID(),
                    user: currentUser,
                    role: .admin,
                    visibilityLevel: type.defaultVisibility,
                    joinedDate: Date()
                )
            ],
            goals: [],
            createdAt: Date()
        )
        circles.append(newCircle)
        addNotification(
            title: "Circle created",
            body: "\(name) is ready. Invite members to get started.",
            icon: "person.3.fill"
        )

        // Persist to backend in the background
        Task {
            do {
                let payload = APICircleCreate(
                    name: name,
                    type: type.rawValue.lowercased(),
                    iconName: iconName,
                    createdBy: currentUser.id
                )
                let apiCircle = try await CircleAPI.create(payload)
                // Update local ID with backend ID if they differ
                if let idx = circles.firstIndex(where: { $0.id == newCircle.id }) {
                    var updated = circles
                    updated[idx] = Circle(
                        id: apiCircle.id,
                        name: updated[idx].name,
                        type: updated[idx].type,
                        iconName: updated[idx].iconName,
                        members: updated[idx].members,
                        goals: updated[idx].goals,
                        createdAt: updated[idx].createdAt
                    )
                    circles = updated
                }
            } catch {
                print("Failed to sync circle to backend: \(error.localizedDescription)")
            }
        }

        return newCircle
    }

    func addMember(_ user: User, to circleId: UUID, role: MemberRole = .member) {
        guard let index = circles.firstIndex(where: { $0.id == circleId }) else { return }
        let member = CircleMember(
            id: UUID(),
            user: user,
            role: role,
            visibilityLevel: circles[index].type.defaultVisibility,
            joinedDate: Date()
        )
        var updated = circles
        updated[index].members.append(member)
        circles = updated
        addNotification(
            title: "New member",
            body: "\(user.name) joined \(circles[index].name)",
            icon: "person.badge.plus"
        )

        Task {
            do {
                let payload = APICircleMemberCreate(
                    circleId: circleId,
                    userId: user.id,
                    role: role.rawValue.lowercased(),
                    visibility: circles[index].type.defaultVisibility.rawValue
                )
                _ = try await CircleAPI.addMember(payload)
            } catch {
                print("Failed to sync member: \(error.localizedDescription)")
            }
        }
    }

    func removeMember(_ memberId: UUID, from circleId: UUID) {
        guard let index = circles.firstIndex(where: { $0.id == circleId }) else { return }
        var updated = circles
        updated[index].members.removeAll { $0.id == memberId }
        circles = updated
    }

    func updateVisibility(_ level: VisibilityLevel, for memberId: UUID, in circleId: UUID) {
        guard let circleIndex = circles.firstIndex(where: { $0.id == circleId }),
              let memberIndex = circles[circleIndex].members.firstIndex(where: { $0.id == memberId }) else {
            return
        }
        var updated = circles
        updated[circleIndex].members[memberIndex].visibilityLevel = level
        circles = updated
    }

    // MARK: - Goals

    func createGoal(
        title: String,
        iconName: String,
        target: Double,
        deadline: Date?,
        circleId: UUID?
    ) -> Goal {
        let newGoal = Goal(
            id: UUID(),
            title: title,
            iconName: iconName,
            targetAmount: target,
            currentAmount: 0,
            deadline: deadline,
            isShared: circleId != nil,
            circleId: circleId,
            contributions: [],
            createdAt: Date()
        )

        if let circleId, let index = circles.firstIndex(where: { $0.id == circleId }) {
            var updated = circles
            updated[index].goals.append(newGoal)
            circles = updated
        } else {
            personalGoals.append(newGoal)
        }

        addNotification(
            title: "New goal",
            body: "\(title) goal created. Start contributing!",
            icon: "target"
        )

        Task {
            do {
                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd"
                let payload = APIGoalCreate(
                    title: title,
                    iconName: iconName,
                    targetAmount: target,
                    currentAmount: 0,
                    deadline: deadline.map { df.string(from: $0) },
                    isShared: circleId != nil,
                    circleId: circleId,
                    ownerId: currentUser.id
                )
                _ = try await GoalAPI.create(payload)
            } catch {
                print("Failed to sync goal: \(error.localizedDescription)")
            }
        }

        return newGoal
    }

    func contribute(_ amount: Double, to goalId: UUID, note: String? = nil) {
        let contribution = Contribution(
            id: UUID(),
            userId: currentUser.id,
            userName: currentUser.name,
            amount: amount,
            date: Date()
        )

        if let index = personalGoals.firstIndex(where: { $0.id == goalId }) {
            var updated = personalGoals
            updated[index].currentAmount += amount
            updated[index].contributions.append(contribution)
            let mutatedGoal = updated[index]
            personalGoals = updated
            checkMilestone(goal: mutatedGoal)
            persistContribution(goalId: goalId, amount: amount, note: note)
            return
        }

        for circleIndex in circles.indices {
            if let goalIndex = circles[circleIndex].goals.firstIndex(where: { $0.id == goalId }) {
                var updatedCircles = circles
                updatedCircles[circleIndex].goals[goalIndex].currentAmount += amount
                updatedCircles[circleIndex].goals[goalIndex].contributions.append(contribution)
                let mutatedGoal = updatedCircles[circleIndex].goals[goalIndex]
                circles = updatedCircles
                checkMilestone(goal: mutatedGoal)
                persistContribution(goalId: goalId, amount: amount, note: note)
                return
            }
        }
    }

    private func persistContribution(goalId: UUID, amount: Double, note: String?) {
        Task {
            do {
                let payload = APIContributionCreate(
                    goalId: goalId,
                    userId: currentUser.id,
                    amount: amount,
                    note: note
                )
                _ = try await GoalAPI.contribute(payload)
            } catch {
                print("Failed to sync contribution: \(error.localizedDescription)")
            }
        }
    }

    func deleteGoal(_ goalId: UUID) {
        personalGoals.removeAll { $0.id == goalId }
        for index in circles.indices {
            var updated = circles
            updated[index].goals.removeAll { $0.id == goalId }
            circles = updated
        }
    }

    private func checkMilestone(goal: Goal) {
        if goal.isCompleted {
            addNotification(
                title: "Goal completed!",
                body: "You reached your \(goal.title) goal. Congratulations!",
                icon: "star.fill"
            )
        } else if goal.progressPercentage >= 0.75 {
            addNotification(
                title: "Almost there",
                body: "\(goal.title) is \(Int(goal.progressPercentage * 100))% complete",
                icon: "flag.fill"
            )
        }
    }

    // MARK: - Notifications

    func addNotification(title: String, body: String, icon: String) {
        let notification = AppNotification(
            id: UUID(),
            title: title,
            body: body,
            icon: icon,
            date: Date(),
            isRead: false
        )
        notifications.insert(notification, at: 0)
    }

    func markNotificationRead(_ id: UUID) {
        if let index = notifications.firstIndex(where: { $0.id == id }) {
            notifications[index].isRead = true
        }
    }

    func markAllNotificationsRead() {
        for index in notifications.indices {
            notifications[index].isRead = true
        }
    }

    var unreadNotificationCount: Int {
        notifications.filter { !$0.isRead }.count
    }

    // MARK: - Computed

    var allGoals: [Goal] {
        var all = personalGoals
        for circle in circles {
            all.append(contentsOf: circle.goals)
        }
        return all
    }

    var totalSaved: Double {
        allGoals.reduce(0) { $0 + $1.currentAmount }
    }

    var totalSpentThisMonth: Double {
        currentStatement?.totalSpent ?? 0
    }
}

// MARK: - Notification Model

struct AppNotification: Identifiable, Hashable {
    let id: UUID
    var title: String
    var body: String
    var icon: String
    var date: Date
    var isRead: Bool
}
