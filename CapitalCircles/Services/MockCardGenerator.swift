import Foundation

/// Generates deterministic mock cards and transactions for a user.
/// The only mock data in the app — cards and transactions are generated
/// per user in the iOS client. Everything else lives in the real Neon database.
enum MockCardGenerator {

    /// Generate 1-3 Capital One cards for the given user, deterministic by user ID.
    static func generateCards(for user: User) -> [Card] {
        var generator = SeededRandom(seed: user.id.hashValue)

        // Decide how many cards: 1-3
        let cardCount = generator.int(in: 1...3)

        // Pick card types without repeats
        let availableTypes: [CardType] = [.ventureX, .venture, .savor, .savorOne, .quicksilver, .platinum]
        var shuffled = availableTypes.shuffled(using: &generator.systemGenerator)
        if shuffled.count > cardCount {
            shuffled = Array(shuffled.prefix(cardCount))
        }

        return shuffled.enumerated().map { index, type in
            let lastFour = String(format: "%04d", generator.int(in: 1000...9999))
            let creditLimit = Double(generator.int(in: 5...25)) * 1000
            let balance = creditLimit * Double(generator.int(in: 10...45)) / 100
            let rewards = Double(generator.int(in: 5...50)) * 1000

            return Card(
                id: UUID(),
                name: type.rawValue,
                lastFourDigits: lastFour,
                cardType: type,
                currentBalance: balance,
                creditLimit: creditLimit,
                rewardsBalance: rewards
            )
        }
    }

    /// Generate realistic monthly transactions for a user, deterministic by user ID.
    static func generateTransactions(for user: User, cards: [Card]) -> [Transaction] {
        guard !cards.isEmpty else { return [] }
        var generator = SeededRandom(seed: user.id.hashValue ^ 0x424242)

        let merchants: [(name: String, category: SpendingCategory, minAmount: Int, maxAmount: Int)] = [
            ("Starbucks", .dining, 40, 180),
            ("Uber", .transport, 80, 320),
            ("HEB", .groceries, 400, 2200),
            ("Netflix", .entertainment, 199, 199),
            ("Amazon", .shopping, 150, 1800),
            ("Rappi", .dining, 180, 650),
            ("Gas station", .transport, 400, 900),
            ("Cinepolis", .entertainment, 150, 480),
            ("Soriana", .groceries, 300, 1400),
            ("Spotify", .entertainment, 99, 169),
            ("Walmart", .shopping, 200, 1500),
            ("La Nacional", .dining, 180, 800),
            ("CFE", .bills, 300, 800),
            ("DiDi", .transport, 60, 250),
            ("Pharmacy", .other, 120, 600),
            ("Costco", .groceries, 800, 3500),
            ("Sephora", .shopping, 300, 1800),
            ("Yogurt shop", .dining, 50, 180),
        ]

        let transactionCount = generator.int(in: 8...16)
        var results: [Transaction] = []

        for _ in 0..<transactionCount {
            let merchant = merchants[generator.int(in: 0..<merchants.count)]
            let amount = Double(generator.int(in: merchant.minAmount...merchant.maxAmount))
            let daysAgo = generator.int(in: 1...28)
            let date = Date(timeIntervalSinceNow: -86400 * Double(daysAgo))
            let card = cards[generator.int(in: 0..<cards.count)]

            results.append(Transaction(
                id: UUID(),
                merchantName: merchant.name,
                amount: amount,
                category: merchant.category,
                date: date,
                cardId: card.id
            ))
        }

        return results.sorted { $0.date > $1.date }
    }
}

/// Deterministic pseudo-random number generator seeded by an integer.
/// Used so that mock data is consistent per user across launches.
private struct SeededRandom {
    var systemGenerator: SystemRandomNumberGenerator

    init(seed: Int) {
        // Seed SystemRandomNumberGenerator isn't actually seedable. Use a custom LCG.
        self.systemGenerator = SystemRandomNumberGenerator()
        self.state = UInt64(bitPattern: Int64(seed)) &+ 1
    }

    private var state: UInt64

    mutating func next() -> UInt64 {
        // Linear congruential generator (Numerical Recipes constants)
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }

    mutating func int(in range: ClosedRange<Int>) -> Int {
        let count = UInt64(range.upperBound - range.lowerBound + 1)
        guard count > 0 else { return range.lowerBound }
        return range.lowerBound + Int(next() % count)
    }

    mutating func int(in range: Range<Int>) -> Int {
        let count = UInt64(range.upperBound - range.lowerBound)
        guard count > 0 else { return range.lowerBound }
        return range.lowerBound + Int(next() % count)
    }
}
