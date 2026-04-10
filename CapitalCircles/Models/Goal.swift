import Foundation

struct Goal: Identifiable, Hashable {
    let id: UUID
    var title: String
    var iconName: String
    var targetAmount: Double
    var currentAmount: Double
    var deadline: Date?
    var isShared: Bool
    var circleId: UUID?
    var contributions: [Contribution]
    var createdAt: Date

    var progressPercentage: Double {
        guard targetAmount > 0 else { return 0 }
        return min(currentAmount / targetAmount, 1.0)
    }

    var remainingAmount: Double {
        max(targetAmount - currentAmount, 0)
    }

    var isCompleted: Bool {
        currentAmount >= targetAmount
    }

    /// Estimated completion date based on average monthly contribution
    var estimatedCompletion: Date? {
        guard !contributions.isEmpty, remainingAmount > 0 else { return nil }
        let totalContributed = contributions.reduce(0.0) { $0 + $1.amount }
        let months = Double(contributions.count)
        guard months > 0 else { return nil }
        let avgMonthly = totalContributed / months
        guard avgMonthly > 0 else { return nil }
        let monthsRemaining = remainingAmount / avgMonthly
        return Calendar.current.date(byAdding: .month, value: Int(ceil(monthsRemaining)), to: Date())
    }

    static func == (lhs: Goal, rhs: Goal) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

struct Contribution: Identifiable, Hashable {
    let id: UUID
    var userId: UUID
    var userName: String
    var amount: Double
    var date: Date
}
