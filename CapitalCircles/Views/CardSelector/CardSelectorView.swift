import SwiftUI

struct CardSelectorView: View {
    private let data = MockDataService.shared
    @State private var selectedCategory: SpendingCategory = .dining

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CCTheme.paddingLarge) {
                    // Category picker
                    categoryPicker

                    // Recommendation
                    recommendationCard

                    // All cards comparison
                    cardsComparison
                }
                .padding(.horizontal, CCTheme.paddingMedium)
                .padding(.bottom, CCTheme.paddingLarge)
            }
            .background(CCTheme.backgroundPrimary)
            .navigationTitle("Card Selector")
        }
    }

    // MARK: - Category Picker

    private var categoryPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What are you buying?")
                .font(.headline)
                .foregroundStyle(CCTheme.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(SpendingCategory.allCases, id: \.self) { category in
                        Button {
                            withAnimation { selectedCategory = category }
                        } label: {
                            Label(category.rawValue, systemImage: category.icon)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(selectedCategory == category ? CCTheme.primaryBlue : CCTheme.backgroundCard)
                                .foregroundStyle(selectedCategory == category ? .white : CCTheme.textPrimary)
                                .clipShape(Capsule())
                                .shadow(color: .black.opacity(0.04), radius: 4, y: 1)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Recommendation

    private var recommendationCard: some View {
        let bestCard = bestCardForCategory(selectedCategory)

        return VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.title)
                .foregroundStyle(.yellow)

            Text("Use your \(bestCard.name)")
                .font(.title3.bold())
                .foregroundStyle(CCTheme.textPrimary)

            Text("You'll earn \(String(format: "%.1f", bestCard.cardType.rewardRate(for: selectedCategory)))% back on \(selectedCategory.rawValue.lowercased())")
                .font(.subheadline)
                .foregroundStyle(CCTheme.textSecondary)
                .multilineTextAlignment(.center)

            // Card visual
            RoundedRectangle(cornerRadius: 12)
                .fill(bestCard.cardType.color)
                .frame(height: 100)
                .overlay {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("CAPITAL ONE")
                                .font(.caption.bold())
                            Spacer()
                            Image(systemName: "wave.3.right")
                        }
                        Spacer()
                        Text("**** **** **** \(bestCard.lastFourDigits)")
                            .font(.caption)
                        Text(bestCard.name)
                            .font(.headline)
                    }
                    .foregroundStyle(.white)
                    .padding()
                }
                .padding(.horizontal, CCTheme.paddingLarge)
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
            SectionHeader(title: "All Your Cards", action: nil)

            ForEach(data.currentUser.cards) { card in
                let rate = card.cardType.rewardRate(for: selectedCategory)
                let isBest = card.id == bestCardForCategory(selectedCategory).id

                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(card.cardType.color)
                        .frame(width: 44, height: 28)
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
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(String(format: "%.1f", rate))%")
                            .font(.headline)
                            .foregroundStyle(isBest ? CCTheme.successGreen : CCTheme.textSecondary)
                        if isBest {
                            Text("BEST")
                                .font(.caption2.bold())
                                .foregroundStyle(CCTheme.successGreen)
                        }
                    }
                }
                .padding(CCTheme.paddingMedium)
                .background(isBest ? CCTheme.lightBlue.opacity(0.5) : CCTheme.backgroundCard)
                .clipShape(RoundedRectangle(cornerRadius: CCTheme.cornerRadiusMedium))
                .overlay {
                    if isBest {
                        RoundedRectangle(cornerRadius: CCTheme.cornerRadiusMedium)
                            .stroke(CCTheme.primaryBlue, lineWidth: 1.5)
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func bestCardForCategory(_ category: SpendingCategory) -> Card {
        data.currentUser.cards.max(by: {
            $0.cardType.rewardRate(for: category) < $1.cardType.rewardRate(for: category)
        }) ?? data.currentUser.cards[0]
    }
}

#Preview {
    CardSelectorView()
}
