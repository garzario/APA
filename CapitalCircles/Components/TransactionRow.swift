import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction

    var body: some View {
        HStack(spacing: CCTheme.space4) {
            Image(systemName: transaction.category.icon)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(CCTheme.navy)
                .frame(width: 36, height: 36)
                .background(CCTheme.fog)
                .clipShape(SwiftUI.Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.merchantName)
                    .font(.ccBody)
                    .foregroundStyle(CCTheme.ink)
                Text("\(transaction.category.rawValue) • \(transaction.date.formatted(.dateTime.month(.abbreviated).day()))")
                    .font(.ccFootnote)
                    .foregroundStyle(CCTheme.slate)
            }

            Spacer()

            Text("-$\(Int(transaction.amount).formatted())")
                .font(.ccBody)
                .foregroundStyle(CCTheme.ink)
                .monospacedDigit()
        }
        .padding(.horizontal, CCTheme.space5)
        .padding(.vertical, CCTheme.space4)
        .contentShape(Rectangle())
    }
}
