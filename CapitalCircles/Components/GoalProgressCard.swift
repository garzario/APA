import SwiftUI

struct GoalProgressCard: View {
    let goal: Goal

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: goal.iconName)
                    .font(.title3)
                    .foregroundStyle(CCTheme.accentBlue)
                Text(goal.title)
                    .font(.subheadline.bold())
                    .foregroundStyle(CCTheme.textPrimary)
                Spacer()
                Text("\(Int(goal.progressPercentage * 100))%")
                    .font(.subheadline.bold())
                    .foregroundStyle(CCTheme.primaryBlue)
            }

            ProgressView(value: goal.progressPercentage)
                .tint(progressColor)

            HStack {
                Text("$\(Int(goal.currentAmount).formatted()) / $\(Int(goal.targetAmount).formatted())")
                    .font(.caption)
                    .foregroundStyle(CCTheme.textSecondary)
                Spacer()
                if goal.isShared {
                    Label("Shared", systemImage: "person.2.fill")
                        .font(.caption2)
                        .foregroundStyle(CCTheme.accentBlue)
                }
            }
        }
        .padding(CCTheme.paddingMedium)
        .background(CCTheme.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: CCTheme.cornerRadiusMedium))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }

    private var progressColor: Color {
        if goal.progressPercentage >= 0.75 { return CCTheme.successGreen }
        if goal.progressPercentage >= 0.4 { return CCTheme.accentBlue }
        return CCTheme.warningOrange
    }
}
