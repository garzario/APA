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
        ScrollView {
            VStack(alignment: .leading, spacing: CCTheme.space8) {
                header

                categoryPicker

                if let bestCard {
                    recommendedCard(bestCard)
                }

                allCardsSection

                rewardsSection
            }
            .padding(.vertical, CCTheme.space5)
            .padding(.bottom, CCTheme.space8)
        }
        .background(CCTheme.canvas)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Card optimizer")
                    .font(.ccHeadline)
                    .foregroundStyle(CCTheme.ink)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: CCTheme.space2) {
            Text("MAXIMIZE REWARDS")
                .font(.ccCaption)
                .foregroundStyle(CCTheme.slate)
                .tracking(0.5)
            Text("Pick the right card\nfor every purchase")
                .font(.ccLargeTitle)
                .foregroundStyle(CCTheme.ink)
        }
        .padding(.horizontal, CCTheme.space5)
    }

    private var categoryPicker: some View {
        VStack(alignment: .leading, spacing: CCTheme.space3) {
            Text("WHAT ARE YOU BUYING?")
                .font(.ccCaption)
                .foregroundStyle(CCTheme.slate)
                .tracking(0.5)
                .padding(.horizontal, CCTheme.space5)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: CCTheme.space2) {
                    ForEach(SpendingCategory.allCases, id: \.self) { category in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedCategory = category
                            }
                        } label: {
                            HStack(spacing: CCTheme.space2) {
                                Image(systemName: category.icon)
                                    .font(.system(size: 13, weight: .medium))
                                Text(category.rawValue)
                                    .font(.ccSubhead.weight(selectedCategory == category ? .semibold : .regular))
                            }
                            .foregroundStyle(selectedCategory == category ? .white : CCTheme.ink)
                            .padding(.horizontal, CCTheme.space4)
                            .padding(.vertical, CCTheme.space3)
                            .background(selectedCategory == category ? CCTheme.navy : CCTheme.fog)
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, CCTheme.space5)
            }
        }
    }

    private func recommendedCard(_ card: Card) -> some View {
        VStack(alignment: .leading, spacing: CCTheme.space5) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: CCTheme.space1) {
                    Text("RECOMMENDED")
                        .font(.ccCaption)
                        .foregroundStyle(.white.opacity(0.7))
                        .tracking(0.5)
                    Text("Use your \(card.name)")
                        .font(.ccTitle)
                        .foregroundStyle(.white)
                }
                Spacer()
            }

            HStack(alignment: .firstTextBaseline, spacing: CCTheme.space2) {
                Text("\(String(format: "%.1f", card.cardType.rewardRate(for: selectedCategory)))x")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("on \(selectedCategory.rawValue.lowercased())")
                    .font(.ccBody)
                    .foregroundStyle(.white.opacity(0.85))
            }

            Divider().background(.white.opacity(0.2))

            Text(card.cardType.rewardsDescription)
                .font(.ccFootnote)
                .foregroundStyle(.white.opacity(0.85))
        }
        .padding(CCTheme.space6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CCTheme.navy)
        .clipShape(RoundedRectangle(cornerRadius: CCTheme.radiusLarge))
        .padding(.horizontal, CCTheme.space5)
    }

    private var allCardsSection: some View {
        CCSection("All cards") {
            VStack(spacing: 0) {
                Divider()
                ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                    cardRow(card)
                    if index < cards.count - 1 {
                        Divider().padding(.leading, CCTheme.space5)
                    }
                }
                Divider()
            }
        }
    }

    private func cardRow(_ card: Card) -> some View {
        let rate = card.cardType.rewardRate(for: selectedCategory)
        let isBest = card.id == bestCard?.id

        return HStack(spacing: CCTheme.space4) {
            Image(systemName: "creditcard")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(CCTheme.navy)
                .frame(width: 36, height: 36)
                .background(CCTheme.fog)
                .clipShape(SwiftUI.Circle())

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: CCTheme.space2) {
                    Text(card.name)
                        .font(.ccBody)
                        .foregroundStyle(CCTheme.ink)
                    if isBest {
                        Text("BEST")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white)
                            .tracking(0.5)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(CCTheme.positive)
                            .clipShape(Capsule())
                    }
                }
                Text("•••• \(card.lastFourDigits)")
                    .font(.ccFootnote)
                    .foregroundStyle(CCTheme.slate)
                    .monospacedDigit()
            }

            Spacer()

            Text("\(String(format: "%.1f", rate))x")
                .font(.ccHeadline)
                .foregroundStyle(isBest ? CCTheme.positive : CCTheme.slate)
                .monospacedDigit()
        }
        .padding(.horizontal, CCTheme.space5)
        .padding(.vertical, CCTheme.space4)
    }

    private var rewardsSection: some View {
        CCSection("Your rewards") {
            VStack(spacing: 0) {
                Divider()
                ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                    HStack {
                        Text(card.name)
                            .font(.ccBody)
                            .foregroundStyle(CCTheme.ink)
                        Spacer()
                        Text("\(Int(card.rewardsBalance).formatted())")
                            .font(.ccBody)
                            .foregroundStyle(CCTheme.ink)
                            .monospacedDigit()
                        Text(card.cardType == .quicksilver ? "cash" : "miles")
                            .font(.ccFootnote)
                            .foregroundStyle(CCTheme.slate)
                    }
                    .padding(.horizontal, CCTheme.space5)
                    .padding(.vertical, CCTheme.space4)
                    if index < cards.count - 1 {
                        Divider().padding(.leading, CCTheme.space5)
                    }
                }
                Divider()
            }
        }
    }
}
