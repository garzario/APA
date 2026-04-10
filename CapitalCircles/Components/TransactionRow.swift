import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction

    var body: some View {
        HStack(spacing: 12) {
            // Category icon
            ZStack {
                SwiftUI.Circle()
                    .fill(CCTheme.lightBlue)
                    .frame(width: 40, height: 40)
                Image(systemName: transaction.category.icon)
                    .font(.system(size: 16))
                    .foregroundStyle(CCTheme.primaryBlue)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.merchantName)
                    .font(.subheadline.bold())
                    .foregroundStyle(CCTheme.textPrimary)
                Text(transaction.date, format: .dateTime.month(.abbreviated).day())
                    .font(.caption)
                    .foregroundStyle(CCTheme.textSecondary)
            }

            Spacer()

            Text("-$\(Int(transaction.amount).formatted())")
                .font(.subheadline.bold())
                .foregroundStyle(CCTheme.textPrimary)
        }
        .padding(.vertical, 6)
    }
}
