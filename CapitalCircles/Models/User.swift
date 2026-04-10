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

/// Roles a member can hold in a circle.
/// The label displayed adapts to the circle type (e.g. "admin" becomes
/// "Parent" in a family, "Partner" in a couple, "Organizer" in friends).
enum MemberRole: String, CaseIterable, Codable {
    case admin = "Admin"
    case member = "Member"
    case junior = "Junior"

    /// Label shown in UI, adapted to the circle type
    func label(for type: CircleType) -> String {
        switch (self, type) {
        case (.admin, .family): return "Parent"
        case (.admin, .couple): return "Partner"
        case (.admin, .roommates): return "Lead"
        case (.admin, .friends): return "Organizer"
        case (.member, .family): return "Family"
        case (.member, .couple): return "Partner"
        case (.member, .roommates): return "Roommate"
        case (.member, .friends): return "Friend"
        case (.junior, .family): return "Child"
        case (.junior, _): return "Junior"
        }
    }

    /// Whether this role can view another member's cards and spending,
    /// given the circle type and the other member's role.
    func canViewSpending(of otherRole: MemberRole, in type: CircleType) -> Bool {
        switch type {
        case .family:
            // Parents (admin) can view children (junior) spending.
            // Juniors NEVER see parent finances.
            // Parents can see other parents only if opted in (handled by visibility).
            if self == .admin && otherRole == .junior { return true }
            return false
        case .couple:
            // Partners see each other if both opted in via visibility level.
            return true
        case .roommates, .friends:
            // Never see personal spending in roommate or friend circles.
            return false
        }
    }

    var canCreateGoals: Bool {
        self != .junior
    }

    var canManageCircle: Bool {
        self == .admin
    }

    var canInviteMembers: Bool {
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
