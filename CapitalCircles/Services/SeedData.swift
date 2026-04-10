import Foundation

/// Seed data used to populate AppStateManager on first launch.
/// In production this would come from the backend API after authentication.
enum SeedData {

    struct SeedPayload {
        let currentUser: User
        let allUsers: [User]
        let circles: [Circle]
        let personalGoals: [Goal]
        let transactions: [Transaction]
        let statements: [SmartStatement]
        let notifications: [AppNotification]
    }

    /// Returns just the statements without loading any users/circles.
    /// The rest of the app state loads from the real backend.
    static func generateStatements() -> [SmartStatement] {
        let seed = generate()
        return seed.statements
    }

    static func generate() -> SeedPayload {
        // Card templates
        let ventureX = Card(
            id: UUID(uuidString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!,
            name: "Venture X",
            lastFourDigits: "4821",
            cardType: .ventureX,
            currentBalance: 2340.50,
            creditLimit: 15000,
            rewardsBalance: 45200
        )

        let savor = Card(
            id: UUID(uuidString: "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB")!,
            name: "Savor One",
            lastFourDigits: "7193",
            cardType: .savor,
            currentBalance: 890.25,
            creditLimit: 8000,
            rewardsBalance: 12500
        )

        let quicksilver = Card(
            id: UUID(uuidString: "CCCCCCCC-CCCC-CCCC-CCCC-CCCCCCCCCCCC")!,
            name: "Quicksilver",
            lastFourDigits: "3056",
            cardType: .quicksilver,
            currentBalance: 1200,
            creditLimit: 10000,
            rewardsBalance: 8900
        )

        let venture = Card(
            id: UUID(uuidString: "DDDDDDDD-DDDD-DDDD-DDDD-DDDDDDDDDDDD")!,
            name: "Venture",
            lastFourDigits: "9247",
            cardType: .venture,
            currentBalance: 3100,
            creditLimit: 12000,
            rewardsBalance: 32000
        )

        // Transactions
        let transactions: [Transaction] = [
            Transaction(id: UUID(), merchantName: "Starbucks", amount: 89, category: .dining, date: day(-1), cardId: savor.id),
            Transaction(id: UUID(), merchantName: "Uber", amount: 245, category: .transport, date: day(-2), cardId: ventureX.id),
            Transaction(id: UUID(), merchantName: "HEB", amount: 1250, category: .groceries, date: day(-3), cardId: savor.id),
            Transaction(id: UUID(), merchantName: "Netflix", amount: 199, category: .entertainment, date: day(-5), cardId: savor.id),
            Transaction(id: UUID(), merchantName: "Amazon", amount: 850, category: .shopping, date: day(-6), cardId: ventureX.id),
            Transaction(id: UUID(), merchantName: "Marriott", amount: 3200, category: .travel, date: day(-7), cardId: ventureX.id),
            Transaction(id: UUID(), merchantName: "Cinepolis", amount: 320, category: .entertainment, date: day(-8), cardId: savor.id),
            Transaction(id: UUID(), merchantName: "Soriana", amount: 980, category: .groceries, date: day(-9), cardId: savor.id),
            Transaction(id: UUID(), merchantName: "La Nacional", amount: 650, category: .dining, date: day(-10), cardId: savor.id),
            Transaction(id: UUID(), merchantName: "CFE", amount: 420, category: .bills, date: day(-12), cardId: ventureX.id),
            Transaction(id: UUID(), merchantName: "Spotify", amount: 169, category: .entertainment, date: day(-14), cardId: savor.id),
            Transaction(id: UUID(), merchantName: "Oxxo", amount: 250, category: .groceries, date: day(-15), cardId: savor.id),
        ]

        // Maria's transactions (different profile: more groceries, less entertainment)
        let mariaTransactions: [Transaction] = [
            Transaction(id: UUID(), merchantName: "Costco", amount: 2450, category: .groceries, date: day(-2), cardId: quicksilver.id),
            Transaction(id: UUID(), merchantName: "Walmart", amount: 680, category: .groceries, date: day(-4), cardId: quicksilver.id),
            Transaction(id: UUID(), merchantName: "Nails Spa", amount: 450, category: .other, date: day(-5), cardId: quicksilver.id),
            Transaction(id: UUID(), merchantName: "Liverpool", amount: 1200, category: .shopping, date: day(-8), cardId: quicksilver.id),
            Transaction(id: UUID(), merchantName: "Pharmacy", amount: 280, category: .other, date: day(-9), cardId: quicksilver.id),
            Transaction(id: UUID(), merchantName: "Gas station", amount: 620, category: .transport, date: day(-11), cardId: quicksilver.id),
            Transaction(id: UUID(), merchantName: "Sams Club", amount: 1450, category: .groceries, date: day(-14), cardId: quicksilver.id),
        ]

        // Diego's transactions (a teen: small amounts, snacks, games)
        let diegoTransactions: [Transaction] = [
            Transaction(id: UUID(), merchantName: "7-Eleven", amount: 45, category: .dining, date: day(-1), cardId: UUID()),
            Transaction(id: UUID(), merchantName: "Cinepolis", amount: 180, category: .entertainment, date: day(-3), cardId: UUID()),
            Transaction(id: UUID(), merchantName: "Nintendo eShop", amount: 59, category: .entertainment, date: day(-6), cardId: UUID()),
            Transaction(id: UUID(), merchantName: "Dominos", amount: 220, category: .dining, date: day(-8), cardId: UUID()),
            Transaction(id: UUID(), merchantName: "School cafeteria", amount: 85, category: .dining, date: day(-10), cardId: UUID()),
            Transaction(id: UUID(), merchantName: "Spotify", amount: 99, category: .entertainment, date: day(-12), cardId: UUID()),
        ]

        // Adan's transactions
        let adanTransactions: [Transaction] = [
            Transaction(id: UUID(), merchantName: "Rappi", amount: 340, category: .dining, date: day(-2), cardId: venture.id),
            Transaction(id: UUID(), merchantName: "DiDi", amount: 145, category: .transport, date: day(-4), cardId: venture.id),
            Transaction(id: UUID(), merchantName: "Amazon", amount: 780, category: .shopping, date: day(-6), cardId: venture.id),
            Transaction(id: UUID(), merchantName: "Steam", amount: 420, category: .entertainment, date: day(-9), cardId: venture.id),
            Transaction(id: UUID(), merchantName: "HEB", amount: 890, category: .groceries, date: day(-12), cardId: venture.id),
        ]

        // Alana's transactions
        let alanaTransactions: [Transaction] = [
            Transaction(id: UUID(), merchantName: "Starbucks", amount: 125, category: .dining, date: day(-1), cardId: savor.id),
            Transaction(id: UUID(), merchantName: "Apple", amount: 1450, category: .shopping, date: day(-3), cardId: savor.id),
            Transaction(id: UUID(), merchantName: "Yogurt shop", amount: 85, category: .dining, date: day(-5), cardId: savor.id),
            Transaction(id: UUID(), merchantName: "Uber", amount: 165, category: .transport, date: day(-7), cardId: savor.id),
            Transaction(id: UUID(), merchantName: "Netflix", amount: 199, category: .entertainment, date: day(-11), cardId: savor.id),
            Transaction(id: UUID(), merchantName: "Sephora", amount: 890, category: .shopping, date: day(-13), cardId: savor.id),
        ]

        // Users
        let patricio = User(
            id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
            name: "Patricio Garza",
            email: "patriciogzaa@gmail.com",
            avatarIcon: "person.circle.fill",
            cards: [ventureX, savor],
            transactions: transactions,
            joinedDate: Date(timeIntervalSinceNow: -86400 * 300)
        )

        let maria = User(
            id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
            name: "Maria Garza",
            email: "maria.garza@gmail.com",
            avatarIcon: "person.circle",
            cards: [quicksilver],
            transactions: mariaTransactions,
            joinedDate: Date(timeIntervalSinceNow: -86400 * 300)
        )

        // Diego has his own junior card (mock)
        let diegoCard = Card(
            id: UUID(uuidString: "DDDDDDDD-1111-1111-1111-DDDDDDDDDDDD")!,
            name: "Journey Student",
            lastFourDigits: "8834",
            cardType: .platinum,
            currentBalance: 180.00,
            creditLimit: 500,
            rewardsBalance: 240
        )

        let diego = User(
            id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!,
            name: "Diego Garza",
            email: "diego.garza@gmail.com",
            avatarIcon: "figure.child.circle.fill",
            cards: [diegoCard],
            transactions: diegoTransactions,
            joinedDate: Date(timeIntervalSinceNow: -86400 * 180)
        )

        let adan = User(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444444444")!,
            name: "Adan Gonzalez",
            email: "ehecatl16@hotmail.com",
            avatarIcon: "person.fill",
            cards: [venture],
            transactions: adanTransactions,
            joinedDate: Date(timeIntervalSinceNow: -86400 * 250)
        )

        let alana = User(
            id: UUID(uuidString: "55555555-5555-5555-5555-555555555555")!,
            name: "Alana Martinez",
            email: "A00841524@tec.mx",
            avatarIcon: "person.crop.circle.fill",
            cards: [savor],
            transactions: alanaTransactions,
            joinedDate: Date(timeIntervalSinceNow: -86400 * 250)
        )

        // Additional test users for demo purposes
        let sofia = User(
            id: UUID(uuidString: "66666666-6666-6666-6666-666666666666")!,
            name: "Sofia Ramirez",
            email: "sofia.ramirez@gmail.com",
            avatarIcon: "person.fill",
            cards: [],
            transactions: [],
            joinedDate: Date(timeIntervalSinceNow: -86400 * 120)
        )

        let carlos = User(
            id: UUID(uuidString: "77777777-7777-7777-7777-777777777777")!,
            name: "Carlos Mendoza",
            email: "carlos.mendoza@gmail.com",
            avatarIcon: "person.fill",
            cards: [],
            transactions: [],
            joinedDate: Date(timeIntervalSinceNow: -86400 * 90)
        )

        let luisa = User(
            id: UUID(uuidString: "88888888-8888-8888-8888-888888888888")!,
            name: "Luisa Torres",
            email: "luisa.torres@gmail.com",
            avatarIcon: "person.fill",
            cards: [],
            transactions: [],
            joinedDate: Date(timeIntervalSinceNow: -86400 * 60)
        )

        // Circles
        let familyCircleId = UUID(uuidString: "EEEEEEEE-EEEE-EEEE-EEEE-EEEEEEEEEEEE")!
        let teamCircleId = UUID(uuidString: "FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF")!

        let vacationGoal = Goal(
            id: UUID(),
            title: "Cancun Vacation",
            iconName: "sun.max.fill",
            targetAmount: 45000,
            currentAmount: 28500,
            deadline: Date(timeIntervalSinceNow: 86400 * 90),
            isShared: true,
            circleId: familyCircleId,
            contributions: [
                Contribution(id: UUID(), userId: patricio.id, userName: "Patricio", amount: 15000, date: day(-30)),
                Contribution(id: UUID(), userId: maria.id, userName: "Maria", amount: 13500, date: day(-20)),
            ],
            createdAt: day(-120)
        )

        let emergencyGoal = Goal(
            id: UUID(),
            title: "Emergency Fund",
            iconName: "shield.fill",
            targetAmount: 60000,
            currentAmount: 42000,
            deadline: nil,
            isShared: true,
            circleId: familyCircleId,
            contributions: [
                Contribution(id: UUID(), userId: patricio.id, userName: "Patricio", amount: 22000, date: day(-60)),
                Contribution(id: UUID(), userId: maria.id, userName: "Maria", amount: 20000, date: day(-50)),
            ],
            createdAt: day(-180)
        )

        let teamGoal = Goal(
            id: UUID(),
            title: "Team Trip CDMX",
            iconName: "airplane",
            targetAmount: 15000,
            currentAmount: 9200,
            deadline: Date(timeIntervalSinceNow: 86400 * 60),
            isShared: true,
            circleId: teamCircleId,
            contributions: [
                Contribution(id: UUID(), userId: patricio.id, userName: "Patricio", amount: 3500, date: day(-30)),
                Contribution(id: UUID(), userId: adan.id, userName: "Adan", amount: 3200, date: day(-25)),
                Contribution(id: UUID(), userId: alana.id, userName: "Alana", amount: 2500, date: day(-20)),
            ],
            createdAt: day(-90)
        )

        let familyCircle = Circle(
            id: familyCircleId,
            name: "Garza Family",
            type: .family,
            iconName: "house.fill",
            members: [
                CircleMember(id: UUID(), user: patricio, role: .admin, visibilityLevel: .goalsOnly, joinedDate: day(-300)),
                CircleMember(id: UUID(), user: maria, role: .admin, visibilityLevel: .goalsOnly, joinedDate: day(-300)),
                CircleMember(id: UUID(), user: diego, role: .junior, visibilityLevel: .goalsOnly, joinedDate: day(-180)),
            ],
            goals: [vacationGoal, emergencyGoal],
            createdAt: day(-300)
        )

        let teamCircle = Circle(
            id: teamCircleId,
            name: "Team APA",
            type: .friends,
            iconName: "person.3.fill",
            members: [
                CircleMember(id: UUID(), user: patricio, role: .admin, visibilityLevel: .goalsOnly, joinedDate: day(-90)),
                CircleMember(id: UUID(), user: adan, role: .member, visibilityLevel: .goalsOnly, joinedDate: day(-90)),
                CircleMember(id: UUID(), user: alana, role: .member, visibilityLevel: .goalsOnly, joinedDate: day(-90)),
            ],
            goals: [teamGoal],
            createdAt: day(-90)
        )

        // Personal goal
        let personalGoal = Goal(
            id: UUID(),
            title: "MacBook Pro",
            iconName: "laptopcomputer",
            targetAmount: 35000,
            currentAmount: 21000,
            deadline: Date(timeIntervalSinceNow: 86400 * 120),
            isShared: false,
            circleId: nil,
            contributions: [
                Contribution(id: UUID(), userId: patricio.id, userName: "Patricio", amount: 21000, date: day(-45)),
            ],
            createdAt: day(-60)
        )

        // Statements (historical, most recent first)
        // Statements in chronological order: January -> April (oldest first, newest last)
        let statements: [SmartStatement] = [
            SmartStatement(
                id: UUID(),
                month: "January",
                year: 2026,
                narrative: "January was a fresh start. Holiday spending wound down and you began the year with an intentional pace. Good foundation for the months ahead.",
                totalSpent: 9460.00,
                insights: [
                    Insight(id: UUID(), title: "Post-holiday reset", description: "You dropped 22% from December's holiday spike", type: .positive, actionable: nil),
                    Insight(id: UUID(), title: "New year goals set", description: "You created Cancun Vacation and MacBook Pro this month", type: .milestone, actionable: nil),
                    Insight(id: UUID(), title: "Dining up from December", description: "Restaurant habits returning to normal", type: .tip, actionable: "Pick one home-cooked night per week"),
                    Insight(id: UUID(), title: "Bills as expected", description: "Subscription and utility charges were steady", type: .positive, actionable: nil),
                ],
                categoryBreakdown: [
                    CategorySpending(id: UUID(), category: .dining, amount: 2610, percentage: 27.6, changeFromLastMonth: 18),
                    CategorySpending(id: UUID(), category: .groceries, amount: 1412, percentage: 14.9, changeFromLastMonth: -8),
                    CategorySpending(id: UUID(), category: .transport, amount: 1440, percentage: 15.2, changeFromLastMonth: 5),
                    CategorySpending(id: UUID(), category: .entertainment, amount: 965, percentage: 10.2, changeFromLastMonth: -4),
                    CategorySpending(id: UUID(), category: .shopping, amount: 730, percentage: 7.7, changeFromLastMonth: -32),
                    CategorySpending(id: UUID(), category: .bills, amount: 1080, percentage: 11.4, changeFromLastMonth: 0),
                    CategorySpending(id: UUID(), category: .other, amount: 1223, percentage: 12.9, changeFromLastMonth: -2),
                ],
                comparedToLastMonth: -22
            ),
            SmartStatement(
                id: UUID(),
                month: "February",
                year: 2026,
                narrative: "February looked like a careful month. You trimmed dining and entertainment, putting more into the Cancun Vacation goal. Steady and intentional.",
                totalSpent: 9080.00,
                insights: [
                    Insight(id: UUID(), title: "Smallest dining month", description: "Only $2,400 on dining, your lowest since November", type: .positive, actionable: nil),
                    Insight(id: UUID(), title: "Cancun Vacation at 55%", description: "You added $2,000 this month to the family vacation pot", type: .milestone, actionable: nil),
                    Insight(id: UUID(), title: "Grocery costs rising", description: "Grocery spending up $220 compared to January", type: .tip, actionable: "Check for price changes at your usual stores"),
                    Insight(id: UUID(), title: "Rewards milestone", description: "You crossed 40,000 miles on your Venture X", type: .milestone, actionable: "Consider redeeming for a travel upgrade"),
                ],
                categoryBreakdown: [
                    CategorySpending(id: UUID(), category: .dining, amount: 2400, percentage: 26.4, changeFromLastMonth: -8),
                    CategorySpending(id: UUID(), category: .groceries, amount: 1640, percentage: 18.1, changeFromLastMonth: 16),
                    CategorySpending(id: UUID(), category: .transport, amount: 1470, percentage: 16.2, changeFromLastMonth: 2),
                    CategorySpending(id: UUID(), category: .entertainment, amount: 870, percentage: 9.6, changeFromLastMonth: -10),
                    CategorySpending(id: UUID(), category: .shopping, amount: 695, percentage: 7.7, changeFromLastMonth: -5),
                    CategorySpending(id: UUID(), category: .bills, amount: 1095, percentage: 12.1, changeFromLastMonth: 1),
                    CategorySpending(id: UUID(), category: .other, amount: 910, percentage: 10.0, changeFromLastMonth: -12),
                ],
                comparedToLastMonth: -4
            ),
            SmartStatement(
                id: UUID(),
                month: "March",
                year: 2026,
                narrative: "March was a big month. You spent a bit more than February, mostly because of extra dining and a weekend trip. The Emergency Fund crossed the 70% mark, which is real momentum.",
                totalSpent: 9805.00,
                insights: [
                    Insight(id: UUID(), title: "Dining up 14%", description: "Several restaurant weekends added up this month", type: .warning, actionable: "Try cooking more next month"),
                    Insight(id: UUID(), title: "Travel rewards doubled", description: "You earned 2,400 extra miles on your Venture X", type: .positive, actionable: nil),
                    Insight(id: UUID(), title: "Emergency Fund at 70%", description: "The Garza family milestone is within reach", type: .milestone, actionable: nil),
                    Insight(id: UUID(), title: "Subscription creep", description: "A new streaming service added $15 this month", type: .tip, actionable: "Audit your subscriptions quarterly"),
                ],
                categoryBreakdown: [
                    CategorySpending(id: UUID(), category: .dining, amount: 2730, percentage: 27.8, changeFromLastMonth: 14),
                    CategorySpending(id: UUID(), category: .travel, amount: 1850, percentage: 18.9, changeFromLastMonth: 120),
                    CategorySpending(id: UUID(), category: .groceries, amount: 1547, percentage: 15.8, changeFromLastMonth: 8),
                    CategorySpending(id: UUID(), category: .transport, amount: 1425, percentage: 14.5, changeFromLastMonth: -3),
                    CategorySpending(id: UUID(), category: .entertainment, amount: 910, percentage: 9.3, changeFromLastMonth: 5),
                    CategorySpending(id: UUID(), category: .shopping, amount: 740, percentage: 7.5, changeFromLastMonth: 10),
                    CategorySpending(id: UUID(), category: .bills, amount: 603, percentage: 6.2, changeFromLastMonth: 1),
                ],
                comparedToLastMonth: 8
            ),
            SmartStatement(
                id: UUID(),
                month: "April",
                year: 2026,
                narrative: "Great month, Patricio. Your spending is 12% lower than March, mainly driven by less dining out. At this pace, you will hit your MacBook Pro goal two months ahead of schedule.",
                totalSpent: 8623.00,
                insights: [
                    Insight(id: UUID(), title: "Dining down 28%", description: "You spent $761 less on dining compared to last month", type: .positive, actionable: nil),
                    Insight(id: UUID(), title: "Subscription increase", description: "Your streaming services went up $150 this month", type: .warning, actionable: "Review your active subscriptions"),
                    Insight(id: UUID(), title: "Savings acceleration", description: "Save $500 more and hit your MacBook goal early", type: .tip, actionable: "Set up automatic transfers"),
                    Insight(id: UUID(), title: "Vacation goal at 63%", description: "Cancun with the Garza family is on track for July", type: .milestone, actionable: nil),
                ],
                categoryBreakdown: [
                    CategorySpending(id: UUID(), category: .dining, amount: 1969, percentage: 22.8, changeFromLastMonth: -28),
                    CategorySpending(id: UUID(), category: .groceries, amount: 1778, percentage: 20.6, changeFromLastMonth: 15),
                    CategorySpending(id: UUID(), category: .transport, amount: 1354, percentage: 15.7, changeFromLastMonth: -5),
                    CategorySpending(id: UUID(), category: .entertainment, amount: 983, percentage: 11.4, changeFromLastMonth: 8),
                    CategorySpending(id: UUID(), category: .shopping, amount: 845, percentage: 9.8, changeFromLastMonth: -12),
                    CategorySpending(id: UUID(), category: .bills, amount: 1121, percentage: 13.0, changeFromLastMonth: 2),
                    CategorySpending(id: UUID(), category: .other, amount: 573, percentage: 6.7, changeFromLastMonth: -3),
                ],
                comparedToLastMonth: -22
            ),
        ]

        // Notifications
        let notifications: [AppNotification] = [
            AppNotification(id: UUID(), title: "Vacation goal updated", body: "Maria added $500 to Cancun Vacation", icon: "star.fill", date: Date(timeIntervalSinceNow: -3600), isRead: false),
            AppNotification(id: UUID(), title: "Smart insight ready", body: "Your April Smart Statement is available", icon: "sparkles", date: Date(timeIntervalSinceNow: -7200), isRead: false),
            AppNotification(id: UUID(), title: "Dining down 28%", body: "Great job cutting dining expenses this month", icon: "checkmark.circle.fill", date: Date(timeIntervalSinceNow: -86400), isRead: true),
        ]

        return SeedPayload(
            currentUser: patricio,
            allUsers: [patricio, maria, diego, adan, alana, sofia, carlos, luisa],
            circles: [familyCircle, teamCircle],
            personalGoals: [personalGoal],
            transactions: transactions,
            statements: statements,
            notifications: notifications
        )
    }

    private static func day(_ offset: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: offset, to: Date()) ?? Date()
    }
}
