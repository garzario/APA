import SwiftUI

/// A refined goal card used in list contexts where a full row is needed.
/// For tight list views, prefer `GoalListRow` from HomeView.
struct GoalProgressCard: View {
    let goal: Goal

    var body: some View {
        VStack(alignment: .leading, spacing: CCTheme.space4) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(goal.title)
                        .font(.ccHeadline)
                        .foregroundStyle(CCTheme.ink)
                    Text("$\(Int(goal.currentAmount).formatted()) of $\(Int(goal.targetAmount).formatted())")
                        .font(.ccFootnote)
                        .foregroundStyle(CCTheme.slate)
                }
                Spacer()
                Text("\(Int(goal.progressPercentage * 100))%")
                    .font(.ccHeadline)
                    .foregroundStyle(CCTheme.ink)
                    .monospacedDigit()
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(CCTheme.hairline)
                        .frame(height: 4)
                    Capsule()
                        .fill(CCTheme.navy)
                        .frame(width: geo.size.width * goal.progressPercentage, height: 4)
                }
            }
            .frame(height: 4)

            HStack(spacing: CCTheme.space3) {
                if goal.isShared {
                    HStack(spacing: 4) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 10, weight: .medium))
                        Text("Shared")
                            .font(.ccCaption)
                    }
                    .foregroundStyle(CCTheme.slate)
                }
                if let deadline = goal.deadline {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 10, weight: .medium))
                        Text(deadline.formatted(.dateTime.month(.abbreviated).day()))
                            .font(.ccCaption)
                    }
                    .foregroundStyle(CCTheme.slate)
                }
                Spacer()
            }
        }
        .padding(CCTheme.space5)
        .background(CCTheme.canvas)
        .overlay {
            RoundedRectangle(cornerRadius: CCTheme.radiusMedium)
                .stroke(CCTheme.hairline, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: CCTheme.radiusMedium))
    }
}
