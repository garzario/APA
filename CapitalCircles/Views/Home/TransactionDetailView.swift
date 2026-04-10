import SwiftUI

struct TransactionDetailView: View {
    @Environment(AppStateManager.self) private var state
    @Environment(\.dismiss) private var dismiss
    let transaction: Transaction

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: CCTheme.space7) {
                    heroSection
                    detailsSection
                    if let card = usedCard {
                        rewardsEarnedSection(card)
                    }
                    betterCardTip
                }
                .padding(.vertical, CCTheme.space5)
                .padding(.bottom, CCTheme.space8)
            }
            .background(CCTheme.canvas)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(CCTheme.ink)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Transaction")
                        .font(.ccHeadline)
                        .foregroundStyle(CCTheme.ink)
                }
            }
        }
    }

    private var usedCard: Card? {
        state.currentUser.cards.first(where: { $0.id == transaction.cardId })
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: CCTheme.space3) {
            Text(transaction.category.rawValue.uppercased())
                .font(.ccCaption)
                .foregroundStyle(CCTheme.slate)
                .tracking(0.5)

            Text(transaction.merchantName)
                .font(.ccLargeTitle)
                .foregroundStyle(CCTheme.ink)

            Text("-$\(Int(transaction.amount).formatted())")
                .font(.ccAmountLarge)
                .foregroundStyle(CCTheme.ink)
                .monospacedDigit()
        }
        .padding(.horizontal, CCTheme.space5)
    }

    // MARK: - Details

    private var detailsSection: some View {
        CCSection("Details") {
            VStack(spacing: 0) {
                Divider()
                row(label: "Date", value: transaction.date.formatted(date: .long, time: .omitted))
                Divider().padding(.leading, CCTheme.space5)
                row(label: "Category", value: transaction.category.rawValue)
                if let card = usedCard {
                    Divider().padding(.leading, CCTheme.space5)
                    row(label: "Card", value: "\(card.name) •••• \(card.lastFourDigits)")
                }
                Divider()
            }
        }
    }

    // MARK: - Rewards Earned

    private func rewardsEarnedSection(_ card: Card) -> some View {
        let rate = card.cardType.rewardRate(for: transaction.category)
        let earned = transaction.amount * rate / 100

        return CCSection("Rewards earned") {
            VStack(spacing: 0) {
                Divider()
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(String(format: "%.1f", rate))x on \(transaction.category.rawValue.lowercased())")
                            .font(.ccBody)
                            .foregroundStyle(CCTheme.ink)
                        Text("with \(card.name)")
                            .font(.ccFootnote)
                            .foregroundStyle(CCTheme.slate)
                    }
                    Spacer()
                    Text("$\(String(format: "%.2f", earned))")
                        .font(.ccBody)
                        .foregroundStyle(CCTheme.positive)
                        .monospacedDigit()
                }
                .padding(.horizontal, CCTheme.space5)
                .padding(.vertical, CCTheme.space4)
                Divider()
            }
        }
    }

    // MARK: - Better Card Tip

    @ViewBuilder
    private var betterCardTip: some View {
        if let used = usedCard,
           let bestCard = bestCard(for: transaction.category),
           bestCard.id != used.id {
            let betterRate = bestCard.cardType.rewardRate(for: transaction.category)
            let usedRate = used.cardType.rewardRate(for: transaction.category)
            let extra = transaction.amount * (betterRate - usedRate) / 100

            VStack(alignment: .leading, spacing: CCTheme.space3) {
                HStack(spacing: CCTheme.space2) {
                    Image(systemName: "lightbulb")
                        .font(.system(size: 12, weight: .medium))
                    Text("TIP")
                        .font(.ccCaption)
                        .tracking(0.5)
                }
                .foregroundStyle(CCTheme.navy)

                Text("Next time, use your ") + Text(bestCard.name).font(.ccBody.bold()).foregroundColor(CCTheme.ink) + Text(" for \(transaction.category.rawValue.lowercased()) to earn $\(String(format: "%.2f", extra)) more in rewards.")
            }
            .font(.ccBody)
            .foregroundStyle(CCTheme.ink)
            .padding(CCTheme.space5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(CCTheme.fog)
            .clipShape(RoundedRectangle(cornerRadius: CCTheme.radiusMedium))
            .padding(.horizontal, CCTheme.space5)
        }
    }

    private func row(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.ccBody)
                .foregroundStyle(CCTheme.slate)
            Spacer()
            Text(value)
                .font(.ccBody)
                .foregroundStyle(CCTheme.ink)
        }
        .padding(.horizontal, CCTheme.space5)
        .padding(.vertical, CCTheme.space4)
    }

    private func bestCard(for category: SpendingCategory) -> Card? {
        state.currentUser.cards.max {
            $0.cardType.rewardRate(for: category) < $1.cardType.rewardRate(for: category)
        }
    }
}
