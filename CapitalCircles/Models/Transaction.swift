import Foundation

struct Transaction: Identifiable, Hashable {
    let id: UUID
    var merchantName: String
    var amount: Double
    var category: SpendingCategory
    var date: Date
    var cardId: UUID

    static func == (lhs: Transaction, rhs: Transaction) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

enum SpendingCategory: String, CaseIterable, Codable {
    case dining = "Dining"
    case groceries = "Groceries"
    case travel = "Travel"
    case entertainment = "Entertainment"
    case transport = "Transport"
    case shopping = "Shopping"
    case bills = "Bills"
    case other = "Other"

    var icon: String {
        switch self {
        case .dining: return "fork.knife"
        case .groceries: return "cart.fill"
        case .travel: return "airplane"
        case .entertainment: return "film.fill"
        case .transport: return "car.fill"
        case .shopping: return "bag.fill"
        case .bills: return "doc.text.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }

}
