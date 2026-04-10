import Foundation

struct User: Identifiable, Hashable {
    let id: UUID
    var name: String
    var email: String
    var avatarIcon: String
    var cards: [Card]
    var transactions: [Transaction]

    // In production, this would come from Capital One's OAuth profile
    var joinedDate: Date

    static func == (lhs: User, rhs: User) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - Circle Membership

struct CircleMember: Identifiable, Hashable {
    let id: UUID
    var user: User
    var role: MemberRole
    var visibilityLevel: VisibilityLevel
    var joinedDate: Date

    static func == (lhs: CircleMember, rhs: CircleMember) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

enum MemberRole: String, CaseIterable, Codable {
    case admin = "Admin"
    case member = "Member"
    case junior = "Junior"

    var canViewMemberSpending: Bool {
        self == .admin
    }

    var canCreateGoals: Bool {
        self != .junior
    }

    var canManageCircle: Bool {
        self == .admin
    }
}

/// Controls what data is visible to other circle members.
/// Privacy by default: nothing shared unless opted in.
enum VisibilityLevel: String, CaseIterable, Codable {
    case goalsOnly = "Goals Only"
    case categories = "Categories"
    case full = "Full"

    var description: String {
        switch self {
        case .goalsOnly: return "Only shared goals and progress"
        case .categories: return "Spending categories without amounts"
        case .full: return "Full spending details"
        }
    }
}
