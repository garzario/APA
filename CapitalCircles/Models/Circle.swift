import Foundation

struct Circle: Identifiable, Hashable {
    let id: UUID
    var name: String
    var type: CircleType
    var iconName: String
    var members: [CircleMember]
    var goals: [Goal]
    var createdAt: Date

    var memberCount: Int { members.count }

    var totalGoalProgress: Double {
        guard !goals.isEmpty else { return 0 }
        let total = goals.reduce(0.0) { $0 + $1.progressPercentage }
        return total / Double(goals.count)
    }

    static func == (lhs: Circle, rhs: Circle) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

enum CircleType: String, CaseIterable, Codable {
    case family = "Family"
    case roommates = "Roommates"
    case friends = "Friends"
    case couple = "Couple"

    var icon: String {
        switch self {
        case .family: return "house.fill"
        case .roommates: return "building.2.fill"
        case .friends: return "person.2.fill"
        case .couple: return "heart.fill"
        }
    }

    var defaultIcon: String {
        icon
    }

    /// Default visibility for new members in this circle type.
    /// Privacy-first: most types default to goals only.
    var defaultVisibility: VisibilityLevel {
        switch self {
        case .family: return .goalsOnly
        case .roommates: return .goalsOnly
        case .friends: return .goalsOnly
        case .couple: return .categories
        }
    }

    /// Whether admin can view junior member spending
    var supportsJuniorRole: Bool {
        self == .family
    }
}
