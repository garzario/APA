import Foundation

/// AI-generated monthly spending summary.
/// Smart Statements turn raw transaction data into human-readable narratives.
struct SmartStatement: Identifiable {
    let id: UUID
    var month: String
    var year: Int
    var narrative: String
    var totalSpent: Double
    var insights: [Insight]
    var categoryBreakdown: [CategorySpending]
    var comparedToLastMonth: Double // percentage change

    var isSpendingUp: Bool { comparedToLastMonth > 0 }
}

struct Insight: Identifiable {
    let id: UUID
    var title: String
    var description: String
    var type: InsightType
    var actionable: String? // optional tip
}

enum InsightType: String, Codable {
    case positive
    case warning
    case tip
    case milestone

    var icon: String {
        switch self {
        case .positive: return "arrow.down.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .tip: return "lightbulb.fill"
        case .milestone: return "star.fill"
        }
    }
}

struct CategorySpending: Identifiable {
    let id: UUID
    var category: SpendingCategory
    var amount: Double
    var percentage: Double
    var changeFromLastMonth: Double
}
