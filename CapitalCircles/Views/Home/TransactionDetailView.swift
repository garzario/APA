import SwiftUI

struct TransactionDetailView: View {
    @Environment(AppStateManager.self) private var state
    @Environment(\.dismiss) private var dismiss
    let transaction: Transaction

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CCTheme.paddingLarge) {
                    // Merchant header
                    VStack(spacing: 12) {
                        Image(systemName: transaction.category.icon)
                            .font(.system(size: 44))
                            .foregroundStyle(CCTheme.primaryBlue)
                            .frame(width: 90, height: 90)
                            .background(CCTheme.lightBlue)
                            .clipShape(SwiftUI.Circle())

                        Text(transaction.merchantName)
                            .font(.title2.bold())
                            .foregroundStyle(CCTheme.textPrimary)

                        Text("-$\(Int(transaction.amount).formatted())")
                            .font(.system(size: 38, weight: .bold, design: .rounded))
                            .foregroundStyle(CCTheme.textPrimary)
                    }
                    .padding(.top, CCTheme.paddingLarge)

                    // Details card
                    VStack(spacing: 0) {
                        detailRow(label: "Category", value: transaction.category.rawValue, icon: transaction.category.icon)
                        Divider().padding(.leading, 56)
                        detailRow(label: "Date", value: transaction.date.formatted(date: .long, time: .omitted), icon: "calendar")
                        Divider().padding(.leading, 56)
                        if let card = state.currentUser.cards.first(where: { $0.id == transaction.cardId }) {
                            detailRow(label: "Card used", value: "\(card.name) • \(card.lastFourDigits)", icon: "creditcard.fill")
                            Divider().padding(.leading, 56)
                            let earned = Int(transaction.amount * card.cardType.rewardRate(for: transaction.category) / 100)
                            detailRow(label: "Rewards earned", value: "$\(earned) cash back", icon: "star.fill")
                        }
                    }
                    .padding(.horizontal, CCTheme.paddingMedium)
                    .background(CCTheme.backgroundCard)
                    .clipShape(RoundedRectangle(cornerRadius: CCTheme.cornerRadiusMedium))
                    .shadow(color: .black.opacity(0.04), radius: 8, y: 2)

                    // Better card tip
                    if let card = state.currentUser.cards.first(where: { $0.id == transaction.cardId }),
                       let bestCard = bestCard(for: transaction.category),
                       bestCard.id != card.id {
                        betterCardTip(used: card, better: bestCard)
                    }
                }
                .padding(.horizontal, CCTheme.paddingMedium)
                .padding(.bottom, CCTheme.paddingLarge)
            }
            .background(CCTheme.backgroundPrimary)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func detailRow(label: String, value: String, icon: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(CCTheme.primaryBlue)
                .frame(width: 32, height: 32)
                .background(CCTheme.lightBlue)
                .clipShape(SwiftUI.Circle())
            Text(label)
                .font(.subheadline)
                .foregroundStyle(CCTheme.textSecondary)
            Spacer()
            Text(value)
                .font(.subheadline.bold())
                .foregroundStyle(CCTheme.textPrimary)
        }
        .padding(.vertical, 14)
    }

    private func betterCardTip(used: Card, better: Card) -> some View {
        let betterRate = better.cardType.rewardRate(for: transaction.category)
        let usedRate = used.cardType.rewardRate(for: transaction.category)
        let extraRewards = Int(transaction.amount * (betterRate - usedRate) / 100)

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(.yellow)
                Text("Tip for next time")
                    .font(.subheadline.bold())
                    .foregroundStyle(CCTheme.textPrimary)
            }
            Text("Using your **\(better.name)** for \(transaction.category.rawValue.lowercased()) would have earned you $\(extraRewards) more in rewards.")
                .font(.caption)
                .foregroundStyle(CCTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(CCTheme.paddingMedium)
        .background(CCTheme.lightBlue.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: CCTheme.cornerRadiusMedium))
    }

    private func bestCard(for category: SpendingCategory) -> Card? {
        state.currentUser.cards.max {
            $0.cardType.rewardRate(for: category) < $1.cardType.rewardRate(for: category)
        }
    }
}
