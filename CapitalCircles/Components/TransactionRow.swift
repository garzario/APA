import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction

    var body: some View {
        HStack(spacing: 14) {
            // Category icon
            Image(systemName: transaction.category.icon)
                .font(.title3)
                .foregroundStyle(CCTheme.primaryBlue)
                .frame(width: 40, height: 40)
                .background(CCTheme.lightBlue)
                .clipShape(SwiftUI.Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.merchantName)
                    .font(.subheadline.bold())
                    .foregroundStyle(CCTheme.textPrimary)
                Text("\(transaction.category.rawValue)  •  \(transaction.date.formatted(.dateTime.month(.abbreviated).day()))")
                    .font(.caption)
                    .foregroundStyle(CCTheme.textSecondary)
            }

            Spacer()

            Text("-$\(Int(transaction.amount).formatted())")
                .font(.subheadline.bold())
                .foregroundStyle(CCTheme.textPrimary)
        }
        .padding(.vertical, 12)
    }
}
