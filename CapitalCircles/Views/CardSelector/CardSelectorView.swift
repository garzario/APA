import SwiftUI

struct CardSelectorView: View {
    @Environment(AppStateManager.self) private var state
    @State private var selectedCategory: SpendingCategory = .dining

    private var cards: [Card] {
        state.currentUser.cards
    }

    private var bestCard: Card? {
        cards.max {
            $0.cardType.rewardRate(for: selectedCategory) < $1.cardType.rewardRate(for: selectedCategory)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CCTheme.paddingLarge) {
                    categoryPicker
                    if let bestCard {
                        recommendationCard(bestCard)
                    }
                    cardsComparison
                    rewardsHistoryCard
                }
                .padding(.horizontal, CCTheme.paddingMedium)
                .padding(.bottom, CCTheme.paddingLarge)
            }
            .background(CCTheme.backgroundPrimary)
            .navigationTitle("Card Optimizer")
        }
    }

    // MARK: - Category Picker

    private var categoryPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What are you buying?")
                .font(.headline)
                .foregroundStyle(CCTheme.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(SpendingCategory.allCases, id: \.self) { category in
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                selectedCategory = category
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: category.icon)
                                    .font(.caption)
                                Text(category.rawValue)
                                    .font(.caption.bold())
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(selectedCategory == category ? CCTheme.primaryBlue : CCTheme.backgroundCard)
                            .foregroundStyle(selectedCategory == category ? .white : CCTheme.textPrimary)
                            .clipShape(Capsule())
                            .shadow(color: .black.opacity(0.04), radius: 4, y: 1)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    // MARK: - Recommendation Card

    private func recommendationCard(_ card: Card) -> some View {
        VStack(spacing: 18) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .foregroundStyle(.yellow)
                Text("Best for \(selectedCategory.rawValue.lowercased())")
                    .font(.caption.bold())
                    .foregroundStyle(CCTheme.textSecondary)
            }

            Text("Use your \(card.name)")
                .font(.title2.bold())
                .foregroundStyle(CCTheme.textPrimary)

            Text("\(String(format: "%.1f", card.cardType.rewardRate(for: selectedCategory)))x rewards")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(CCTheme.primaryBlue)

            // Card visual
            CapitalOneCardView(card: card)
                .frame(height: 180)
                .padding(.horizontal, 20)
        }
        .padding(CCTheme.paddingLarge)
        .frame(maxWidth: .infinity)
        .background(CCTheme.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: CCTheme.cornerRadiusLarge))
        .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
    }

    // MARK: - Cards Comparison

    private var cardsComparison: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("All your cards")
                .font(.headline)
                .foregroundStyle(CCTheme.textPrimary)

            ForEach(cards) { card in
                let rate = card.cardType.rewardRate(for: selectedCategory)
                let isBest = card.id == bestCard?.id

                HStack(spacing: 14) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(card.cardType.color)
                        .frame(width: 48, height: 32)
                        .overlay {
                            Text("C1")
                                .font(.caption2.bold())
                                .foregroundStyle(.white)
                        }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(card.name)
                            .font(.subheadline.bold())
                            .foregroundStyle(CCTheme.textPrimary)
                        Text(card.cardType.rewardsDescription)
                            .font(.caption2)
                            .foregroundStyle(CCTheme.textSecondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(String(format: "%.1f", rate))x")
                            .font(.title3.bold())
                            .foregroundStyle(isBest ? CCTheme.successGreen : CCTheme.textSecondary)
                        if isBest {
                            Text("BEST")
                                .font(.caption2.bold())
                                .foregroundStyle(CCTheme.successGreen)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(CCTheme.successGreen.opacity(0.15))
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(CCTheme.paddingMedium)
                .background(isBest ? CCTheme.lightBlue.opacity(0.5) : CCTheme.backgroundCard)
                .clipShape(RoundedRectangle(cornerRadius: CCTheme.cornerRadiusMedium))
                .overlay {
                    if isBest {
                        RoundedRectangle(cornerRadius: CCTheme.cornerRadiusMedium)
                            .stroke(CCTheme.primaryBlue, lineWidth: 2)
                    }
                }
                .shadow(color: .black.opacity(isBest ? 0.08 : 0.03), radius: 8, y: 2)
            }
        }
    }

    // MARK: - Rewards History

    private var rewardsHistoryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your rewards")
                .font(.headline)
                .foregroundStyle(CCTheme.textPrimary)

            VStack(spacing: 0) {
                ForEach(cards) { card in
                    HStack(spacing: 14) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(card.cardType.color)
                            .frame(width: 36, height: 24)
                            .overlay {
                                Text("C1")
                                    .font(.caption2.bold())
                                    .foregroundStyle(.white)
                            }
                        Text(card.name)
                            .font(.subheadline.bold())
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(Int(card.rewardsBalance).formatted())")
                                .font(.headline)
                                .foregroundStyle(CCTheme.primaryBlue)
                            Text(card.cardType == .quicksilver ? "cash back" : "miles")
                                .font(.caption2)
                                .foregroundStyle(CCTheme.textSecondary)
                        }
                    }
                    .padding(.vertical, 12)
                    if card.id != cards.last?.id {
                        Divider()
                    }
                }
            }
            .padding(.horizontal, CCTheme.paddingMedium)
            .background(CCTheme.backgroundCard)
            .clipShape(RoundedRectangle(cornerRadius: CCTheme.cornerRadiusMedium))
            .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
        }
    }
}

// MARK: - Capital One Card Visual

struct CapitalOneCardView: View {
    let card: Card

    var body: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(
                colors: [card.cardType.color, card.cardType.color.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading) {
                HStack {
                    Text("CAPITAL")
                        .font(.caption2.bold())
                    Text("ONE")
                        .font(.caption2.bold())
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(.white.opacity(0.2))
                    Spacer()
                    Image(systemName: "wave.3.right")
                        .font(.caption)
                }

                Spacer()

                Text("\(String(card.name.prefix(8)).uppercased())")
                    .font(.caption.bold())
                    .opacity(0.7)

                HStack(spacing: 8) {
                    Text("****")
                    Text("****")
                    Text("****")
                    Text(card.lastFourDigits)
                }
                .font(.system(.subheadline, design: .monospaced).bold())
                .padding(.top, 4)

                HStack {
                    Text(card.name)
                        .font(.headline.bold())
                    Spacer()
                    Image(systemName: "visa.logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 16)
                        .opacity(0.9)
                }
                .padding(.top, 2)
            }
            .foregroundStyle(.white)
            .padding(18)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.15), radius: 10, y: 4)
    }
}
