import Foundation
import SwiftUI

/// Central observable state manager for the app.
/// Manages all mutable data: circles, goals, contributions, users.
/// In production, this would sync with the backend API and local SwiftData cache.
@Observable
final class AppStateManager {
    static let shared = AppStateManager()

    // MARK: - Current User

    var currentUser: User
    var allUsers: [User]

    // MARK: - Circles and Goals

    var circles: [Circle]
    var personalGoals: [Goal]

    // MARK: - Transactions and Cards

    var transactions: [Transaction]

    // MARK: - Smart Statements

    /// Historical statements by month, chronological order (oldest first, newest last)
    var statements: [SmartStatement] = []
    var selectedStatementId: UUID?
    var isLoadingStatement: Bool = false

    /// The currently selected statement. Defaults to the most recent (last in chronological order).
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

    // MARK: - Init

    private init() {
        let seed = SeedData.generate()
        self.currentUser = seed.currentUser
        self.allUsers = seed.allUsers
        self.circles = seed.circles
        self.personalGoals = seed.personalGoals
        self.transactions = seed.transactions
        self.statements = seed.statements
        // Default to the most recent month (last in chronological order)
        self.selectedStatementId = seed.statements.last?.id
        self.notifications = seed.notifications
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
        circles[index].members.append(member)
        addNotification(
            title: "New member",
            body: "\(user.name) joined \(circles[index].name)",
            icon: "person.badge.plus"
        )
    }

    func removeMember(_ memberId: UUID, from circleId: UUID) {
        guard let index = circles.firstIndex(where: { $0.id == circleId }) else { return }
        circles[index].members.removeAll { $0.id == memberId }
    }

    func updateVisibility(_ level: VisibilityLevel, for memberId: UUID, in circleId: UUID) {
        guard let circleIndex = circles.firstIndex(where: { $0.id == circleId }),
              let memberIndex = circles[circleIndex].members.firstIndex(where: { $0.id == memberId }) else {
            return
        }
        circles[circleIndex].members[memberIndex].visibilityLevel = level
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
            circles[index].goals.append(newGoal)
        } else {
            personalGoals.append(newGoal)
        }

        addNotification(
            title: "New goal",
            body: "\(title) goal created. Start contributing!",
            icon: "target"
        )

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

        // Try personal goals first — reassign the full array so @Observable
        // reliably triggers UI updates across all reading views.
        if let index = personalGoals.firstIndex(where: { $0.id == goalId }) {
            var updated = personalGoals
            updated[index].currentAmount += amount
            updated[index].contributions.append(contribution)
            let mutatedGoal = updated[index]
            personalGoals = updated
            checkMilestone(goal: mutatedGoal)
            return
        }

        // Otherwise look in circles — same reassignment pattern
        for circleIndex in circles.indices {
            if let goalIndex = circles[circleIndex].goals.firstIndex(where: { $0.id == goalId }) {
                var updatedCircles = circles
                updatedCircles[circleIndex].goals[goalIndex].currentAmount += amount
                updatedCircles[circleIndex].goals[goalIndex].contributions.append(contribution)
                let mutatedGoal = updatedCircles[circleIndex].goals[goalIndex]
                circles = updatedCircles
                checkMilestone(goal: mutatedGoal)
                return
            }
        }
    }

    func deleteGoal(_ goalId: UUID) {
        personalGoals.removeAll { $0.id == goalId }
        for index in circles.indices {
            circles[index].goals.removeAll { $0.id == goalId }
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
