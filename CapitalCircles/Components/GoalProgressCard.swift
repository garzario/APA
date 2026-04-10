import SwiftUI

struct GoalProgressCard: View {
    let goal: Goal

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: goal.iconName)
                    .font(.title3)
                    .foregroundStyle(CCTheme.primaryBlue)
                    .frame(width: 44, height: 44)
                    .background(CCTheme.lightBlue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 2) {
                    Text(goal.title)
                        .font(.subheadline.bold())
                        .foregroundStyle(CCTheme.textPrimary)
                    HStack(spacing: 6) {
                        Text("$\(Int(goal.currentAmount).formatted())")
                            .font(.caption)
                            .foregroundStyle(CCTheme.textPrimary)
                        Text("of $\(Int(goal.targetAmount).formatted())")
                            .font(.caption)
                            .foregroundStyle(CCTheme.textSecondary)
                    }
                }

                Spacer()

                Text("\(Int(goal.progressPercentage * 100))%")
                    .font(.title3.bold())
                    .foregroundStyle(progressColor)
            }

            ProgressView(value: goal.progressPercentage)
                .tint(progressColor)
                .scaleEffect(x: 1, y: 1.5, anchor: .center)

            HStack {
                if goal.isShared {
                    Label("Shared", systemImage: "person.2.fill")
                        .font(.caption2.bold())
                        .foregroundStyle(CCTheme.accentBlue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(CCTheme.lightBlue)
                        .clipShape(Capsule())
                }
                Spacer()
                if let deadline = goal.deadline {
                    Label(deadline.formatted(.dateTime.month(.abbreviated).day()), systemImage: "calendar")
                        .font(.caption2)
                        .foregroundStyle(CCTheme.textSecondary)
                }
            }
        }
        .padding(CCTheme.paddingMedium)
        .background(CCTheme.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: CCTheme.cornerRadiusMedium))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }

    private var progressColor: Color {
        if goal.progressPercentage >= 0.75 { return CCTheme.successGreen }
        if goal.progressPercentage >= 0.4 { return CCTheme.primaryBlue }
        return CCTheme.warningOrange
    }
}
