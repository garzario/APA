import Foundation

/// Provides realistic mock data for the MVP.
/// In production, this would be replaced by Capital One's API layer
/// with proper authentication, rate limiting, and data encryption.
final class MockDataService {
    static let shared = MockDataService()

    // MARK: - Users

    lazy var currentUser: User = {
        User(
            id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
            name: "Patricio Garza",
            email: "patriciogzaa@gmail.com",
            avatarIcon: "person.circle.fill",
            cards: [ventureXCard, savorCard],
            transactions: generateTransactions(),
            joinedDate: date(2025, 6, 15)
        )
    }()

    lazy var familyMembers: [User] = [
        User(
            id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
            name: "Maria Garza",
            email: "maria@gmail.com",
            avatarIcon: "person.circle",
            cards: [quicksilverCard],
            transactions: [],
            joinedDate: date(2025, 6, 15)
        ),
        User(
            id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!,
            name: "Diego Garza",
            email: "diego@gmail.com",
            avatarIcon: "figure.child",
            cards: [],
            transactions: [],
            joinedDate: date(2025, 8, 1)
        )
    ]

    lazy var friends: [User] = [
        User(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444444444")!,
            name: "Adan Gonzalez",
            email: "ehecatl16@hotmail.com",
            avatarIcon: "person.fill",
            cards: [ventureCard],
            transactions: [],
            joinedDate: date(2025, 7, 1)
        ),
        User(
            id: UUID(uuidString: "55555555-5555-5555-5555-555555555555")!,
            name: "Alana Martinez",
            email: "alana@tec.mx",
            avatarIcon: "person.crop.circle",
            cards: [savorCard],
            transactions: [],
            joinedDate: date(2025, 7, 1)
        )
    ]

    // MARK: - Cards

    let ventureXCard = Card(
        id: UUID(uuidString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!,
        name: "Venture X",
        lastFourDigits: "4821",
        cardType: .ventureX,
        currentBalance: 2340.50,
        creditLimit: 15000,
        rewardsBalance: 45200
    )

    let savorCard = Card(
        id: UUID(uuidString: "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB")!,
        name: "Savor One",
        lastFourDigits: "7193",
        cardType: .savor,
        currentBalance: 890.25,
        creditLimit: 8000,
        rewardsBalance: 12500
    )

    let quicksilverCard = Card(
        id: UUID(uuidString: "CCCCCCCC-CCCC-CCCC-CCCC-CCCCCCCCCCCC")!,
        name: "Quicksilver",
        lastFourDigits: "3056",
        cardType: .quicksilver,
        currentBalance: 1200.00,
        creditLimit: 10000,
        rewardsBalance: 8900
    )

    let ventureCard = Card(
        id: UUID(uuidString: "DDDDDDDD-DDDD-DDDD-DDDD-DDDDDDDDDDDD")!,
        name: "Venture",
        lastFourDigits: "9247",
        cardType: .venture,
        currentBalance: 3100.00,
        creditLimit: 12000,
        rewardsBalance: 32000
    )

    // MARK: - Circles

    lazy var circles: [Circle] = [
        Circle(
            id: UUID(uuidString: "EEEEEEEE-EEEE-EEEE-EEEE-EEEEEEEEEEEE")!,
            name: "Garza Family",
            type: .family,
            iconName: "house.fill",
            members: [
                CircleMember(id: UUID(), user: currentUser, role: .admin, visibilityLevel: .goalsOnly, joinedDate: date(2025, 6, 15)),
                CircleMember(id: UUID(), user: familyMembers[0], role: .admin, visibilityLevel: .goalsOnly, joinedDate: date(2025, 6, 15)),
                CircleMember(id: UUID(), user: familyMembers[1], role: .junior, visibilityLevel: .goalsOnly, joinedDate: date(2025, 8, 1))
            ],
            goals: [familyVacationGoal, emergencyFundGoal],
            createdAt: date(2025, 6, 15)
        ),
        Circle(
            id: UUID(uuidString: "FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF")!,
            name: "Team APA",
            type: .friends,
            iconName: "person.2.fill",
            members: [
                CircleMember(id: UUID(), user: currentUser, role: .member, visibilityLevel: .goalsOnly, joinedDate: date(2025, 7, 1)),
                CircleMember(id: UUID(), user: friends[0], role: .member, visibilityLevel: .goalsOnly, joinedDate: date(2025, 7, 1)),
                CircleMember(id: UUID(), user: friends[1], role: .member, visibilityLevel: .goalsOnly, joinedDate: date(2025, 7, 1))
            ],
            goals: [teamTripGoal],
            createdAt: date(2025, 7, 1)
        )
    ]

    // MARK: - Goals

    lazy var familyVacationGoal = Goal(
        id: UUID(),
        title: "Cancun Vacation",
        iconName: "sun.max.fill",
        targetAmount: 45000,
        currentAmount: 28500,
        deadline: date(2026, 7, 15),
        isShared: true,
        circleId: UUID(uuidString: "EEEEEEEE-EEEE-EEEE-EEEE-EEEEEEEEEEEE")!,
        contributions: [
            Contribution(id: UUID(), userId: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!, userName: "Patricio", amount: 15000, date: date(2026, 3, 1)),
            Contribution(id: UUID(), userId: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!, userName: "Maria", amount: 13500, date: date(2026, 3, 15))
        ],
        createdAt: date(2025, 12, 1)
    )

    lazy var emergencyFundGoal = Goal(
        id: UUID(),
        title: "Emergency Fund",
        iconName: "shield.fill",
        targetAmount: 60000,
        currentAmount: 42000,
        deadline: nil,
        isShared: true,
        circleId: UUID(uuidString: "EEEEEEEE-EEEE-EEEE-EEEE-EEEEEEEEEEEE")!,
        contributions: [
            Contribution(id: UUID(), userId: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!, userName: "Patricio", amount: 22000, date: date(2026, 2, 1)),
            Contribution(id: UUID(), userId: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!, userName: "Maria", amount: 20000, date: date(2026, 2, 15))
        ],
        createdAt: date(2025, 9, 1)
    )

    lazy var teamTripGoal = Goal(
        id: UUID(),
        title: "Team Trip CDMX",
        iconName: "airplane",
        targetAmount: 15000,
        currentAmount: 9200,
        deadline: date(2026, 5, 20),
        isShared: true,
        circleId: UUID(uuidString: "FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF")!,
        contributions: [
            Contribution(id: UUID(), userId: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!, userName: "Patricio", amount: 3500, date: date(2026, 3, 1)),
            Contribution(id: UUID(), userId: UUID(uuidString: "44444444-4444-4444-4444-444444444444")!, userName: "Adan", amount: 3200, date: date(2026, 3, 5)),
            Contribution(id: UUID(), userId: UUID(uuidString: "55555555-5555-5555-5555-555555555555")!, userName: "Alana", amount: 2500, date: date(2026, 3, 10))
        ],
        createdAt: date(2026, 1, 15)
    )

    lazy var personalGoal = Goal(
        id: UUID(),
        title: "MacBook Pro",
        iconName: "laptopcomputer",
        targetAmount: 35000,
        currentAmount: 21000,
        deadline: date(2026, 8, 1),
        isShared: false,
        circleId: nil,
        contributions: [
            Contribution(id: UUID(), userId: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!, userName: "Patricio", amount: 21000, date: date(2026, 3, 1))
        ],
        createdAt: date(2026, 1, 1)
    )

    // MARK: - Smart Statement

    lazy var currentStatement: SmartStatement = SmartStatement(
        id: UUID(),
        month: "March",
        year: 2026,
        narrative: "This month you spent 12% less than February. Your dining spending dropped significantly after switching to cooking more at home. Your Venture X earned you 1,200 extra miles from travel purchases. Keep it up!",
        totalSpent: 18450.00,
        insights: [
            Insight(id: UUID(), title: "Dining down 28%", description: "You spent $2,100 less on dining compared to last month", type: .positive, actionable: nil),
            Insight(id: UUID(), title: "Subscription alert", description: "Your streaming services increased by $150 this month", type: .warning, actionable: "Review your active subscriptions in Settings"),
            Insight(id: UUID(), title: "Savings tip", description: "If you save $3,000 extra this month, you'll hit your MacBook goal 2 months early", type: .tip, actionable: "Set up automatic transfers to your savings"),
            Insight(id: UUID(), title: "Vacation goal at 63%!", description: "Your family vacation goal is on track for July", type: .milestone, actionable: nil)
        ],
        categoryBreakdown: [
            CategorySpending(id: UUID(), category: .dining, amount: 4200, percentage: 22.8, changeFromLastMonth: -28),
            CategorySpending(id: UUID(), category: .groceries, amount: 3800, percentage: 20.6, changeFromLastMonth: 15),
            CategorySpending(id: UUID(), category: .transport, amount: 2900, percentage: 15.7, changeFromLastMonth: -5),
            CategorySpending(id: UUID(), category: .entertainment, amount: 2100, percentage: 11.4, changeFromLastMonth: 8),
            CategorySpending(id: UUID(), category: .shopping, amount: 1800, percentage: 9.8, changeFromLastMonth: -12),
            CategorySpending(id: UUID(), category: .bills, amount: 2400, percentage: 13.0, changeFromLastMonth: 2),
            CategorySpending(id: UUID(), category: .other, amount: 1250, percentage: 6.8, changeFromLastMonth: -3)
        ],
        comparedToLastMonth: -12
    )

    // MARK: - Helpers

    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: day))!
    }

    private func generateTransactions() -> [Transaction] {
        let cardId = UUID(uuidString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!
        let savorId = UUID(uuidString: "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB")!

        return [
            Transaction(id: UUID(), merchantName: "Starbucks", amount: 89, category: .dining, date: date(2026, 4, 9), cardId: savorId),
            Transaction(id: UUID(), merchantName: "Uber", amount: 245, category: .transport, date: date(2026, 4, 8), cardId: cardId),
            Transaction(id: UUID(), merchantName: "HEB", amount: 1250, category: .groceries, date: date(2026, 4, 7), cardId: savorId),
            Transaction(id: UUID(), merchantName: "Netflix", amount: 199, category: .entertainment, date: date(2026, 4, 5), cardId: savorId),
            Transaction(id: UUID(), merchantName: "Amazon", amount: 850, category: .shopping, date: date(2026, 4, 4), cardId: cardId),
            Transaction(id: UUID(), merchantName: "Marriott", amount: 3200, category: .travel, date: date(2026, 4, 3), cardId: cardId),
            Transaction(id: UUID(), merchantName: "Cinepolis", amount: 320, category: .entertainment, date: date(2026, 4, 2), cardId: savorId),
            Transaction(id: UUID(), merchantName: "Soriana", amount: 980, category: .groceries, date: date(2026, 4, 1), cardId: savorId),
            Transaction(id: UUID(), merchantName: "La Nacional", amount: 650, category: .dining, date: date(2026, 3, 30), cardId: savorId),
            Transaction(id: UUID(), merchantName: "CFE", amount: 420, category: .bills, date: date(2026, 3, 28), cardId: cardId),
        ]
    }
}
