import SwiftUI

/// Represents a Capital One credit card with its rewards structure.
/// Card designs and reward rates mirror Capital One's real consumer cards
/// as of 2026. In production this would come from Capital One's Card API.
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
    case ventureX = "Venture X Rewards"
    case venture = "Venture Rewards"
    case savor = "Savor Rewards"
    case savorOne = "SavorOne Rewards"
    case quicksilver = "Quicksilver Cash Rewards"
    case platinum = "Platinum"

    /// Primary card color based on the real Capital One design system.
    var primaryColor: Color {
        switch self {
        case .ventureX: return Color(hex: "#1C1C1E")      // obsidian
        case .venture: return Color(hex: "#003057")        // navy
        case .savor: return Color(hex: "#8B0000")          // deep red
        case .savorOne: return Color(hex: "#C41E3A")       // capital one red
        case .quicksilver: return Color(hex: "#A8A9AD")    // brushed silver
        case .platinum: return Color(hex: "#6B7280")       // platinum gray
        }
    }

    /// Secondary color for gradient backgrounds on card visuals
    var secondaryColor: Color {
        switch self {
        case .ventureX: return Color(hex: "#3A3A3C")
        case .venture: return Color(hex: "#1A4577")
        case .savor: return Color(hex: "#5C0000")
        case .savorOne: return Color(hex: "#8B0E1D")
        case .quicksilver: return Color(hex: "#6B6D75")
        case .platinum: return Color(hex: "#4B5159")
        }
    }

    /// Legacy color property for backwards compatibility
    var color: Color { primaryColor }

    var tagline: String {
        switch self {
        case .ventureX: return "Travel Premier"
        case .venture: return "Travel"
        case .savor: return "Dining & Entertainment"
        case .savorOne: return "Everyday Rewards"
        case .quicksilver: return "Cash Back"
        case .platinum: return "Build Credit"
        }
    }

    var rewardsDescription: String {
        switch self {
        case .ventureX: return "2X miles on everything, 10X on hotels, 5X on flights booked through Capital One Travel"
        case .venture: return "2X miles on every purchase, every day"
        case .savor: return "4% on dining, entertainment & streaming, 3% on groceries, 1% everywhere"
        case .savorOne: return "3% on dining, entertainment, groceries & streaming"
        case .quicksilver: return "1.5% cash back on every purchase"
        case .platinum: return "Build credit responsibly with no annual fee"
        }
    }

    /// Annual fee in USD
    var annualFee: Int {
        switch self {
        case .ventureX: return 395
        case .venture: return 95
        case .savor: return 95
        case .savorOne, .quicksilver, .platinum: return 0
        }
    }

    /// Reward rates per spending category (as multipliers or percentages)
    var rewardRates: [SpendingCategory: Double] {
        switch self {
        case .ventureX:
            return [
                .dining: 2.0, .travel: 10.0, .groceries: 2.0,
                .entertainment: 2.0, .transport: 2.0, .shopping: 2.0,
                .bills: 2.0, .other: 2.0
            ]
        case .venture:
            return [
                .dining: 2.0, .travel: 5.0, .groceries: 2.0,
                .entertainment: 2.0, .transport: 2.0, .shopping: 2.0,
                .bills: 2.0, .other: 2.0
            ]
        case .savor:
            return [
                .dining: 4.0, .travel: 1.0, .groceries: 3.0,
                .entertainment: 4.0, .transport: 1.0, .shopping: 1.0,
                .bills: 1.0, .other: 1.0
            ]
        case .savorOne:
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
        case .platinum:
            return [
                .dining: 0, .travel: 0, .groceries: 0,
                .entertainment: 0, .transport: 0, .shopping: 0,
                .bills: 0, .other: 0
            ]
        }
    }

    /// Returns the reward rate for a given spending category
    func rewardRate(for category: SpendingCategory) -> Double {
        rewardRates[category] ?? 1.0
    }
}
