import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(color)
                Spacer()
            }

            Text(value)
                .font(.title2.bold())
                .foregroundStyle(CCTheme.textPrimary)

            Text(title)
                .font(.caption)
                .foregroundStyle(CCTheme.textSecondary)

            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(color)
        }
        .padding(CCTheme.paddingMedium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CCTheme.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: CCTheme.cornerRadiusMedium))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }
}

#Preview {
    StatCard(title: "This Month", value: "$18,450", subtitle: "-12% vs last month", icon: "chart.line.downtrend.xyaxis", color: .green)
        .padding()
}
