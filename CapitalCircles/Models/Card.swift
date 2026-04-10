import SwiftUI

/// Represents a Capital One credit card with its rewards structure.
/// In production, card data would come from Capital One's Card API.
struct Card: Identifiable, Hashable {
    let id: UUID
    var name: String
    var lastFourDigits: String
    var cardType: CardType
    var currentBalance: Double
    var creditLimit: Double
    var rewardsBalance: Double

    var utilizationPercentage: Double {
        guard creditLimit > 0 else { return 0 }
        return currentBalance / creditLimit
    }

    static func == (lhs: Card, rhs: Card) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

enum CardType: String, CaseIterable, Codable {
    case ventureX = "Venture X"
    case savor = "Savor One"
    case quicksilver = "Quicksilver"
    case venture = "Venture"

    var color: Color {
        switch self {
        case .ventureX: return Color(hex: "1A1A2E")
        case .savor: return Color(hex: "2D5016")
        case .quicksilver: return Color(hex: "5A5A5A")
        case .venture: return Color(hex: "1A1A2E")
        }
    }

    var rewardsDescription: String {
        switch self {
        case .ventureX: return "2X miles on everything, 10X on hotels"
        case .savor: return "3% dining, entertainment, grocery"
        case .quicksilver: return "1.5% cash back on everything"
        case .venture: return "2X miles on everything, 5X on hotels"
        }
    }

    /// Reward rates per spending category
    var rewardRates: [SpendingCategory: Double] {
        switch self {
        case .ventureX:
            return [
                .dining: 2.0, .travel: 10.0, .groceries: 2.0,
                .entertainment: 2.0, .transport: 2.0, .shopping: 2.0,
                .bills: 2.0, .other: 2.0
            ]
        case .savor:
            return [
                .dining: 3.0, .travel: 1.0, .groceries: 3.0,
                .entertainment: 3.0, .transport: 1.0, .shopping: 1.0,
                .bills: 1.0, .other: 1.0
            ]
        case .quicksilver:
            return [
                .dining: 1.5, .travel: 1.5, .groceries: 1.5,
                .entertainment: 1.5, .transport: 1.5, .shopping: 1.5,
                .bills: 1.5, .other: 1.5
            ]
        case .venture:
            return [
                .dining: 2.0, .travel: 5.0, .groceries: 2.0,
                .entertainment: 2.0, .transport: 2.0, .shopping: 2.0,
                .bills: 2.0, .other: 2.0
            ]
        }
    }

    /// Returns the reward rate for a given spending category
    func rewardRate(for category: SpendingCategory) -> Double {
        rewardRates[category] ?? 1.0
    }
}
