import SwiftUI

struct CircleDetailView: View {
    let circle: Circle

    var body: some View {
        ScrollView {
            VStack(spacing: CCTheme.paddingLarge) {
                // Circle header
                circleHeader

                // Members section
                membersSection

                // Goals section
                goalsSection
            }
            .padding(.horizontal, CCTheme.paddingMedium)
        }
        .background(CCTheme.backgroundPrimary)
        .navigationTitle(circle.name)
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Header

    private var circleHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: circle.iconName)
                .font(.system(size: 50))
                .foregroundStyle(CCTheme.primaryBlue)

            Text(circle.type.rawValue)
                .font(.subheadline)
                .foregroundStyle(CCTheme.textSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(CCTheme.lightBlue)
                .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, CCTheme.paddingMedium)
    }

    // MARK: - Members

    private var membersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Members", action: nil)

            ForEach(circle.members) { member in
                HStack(spacing: 12) {
                    Image(systemName: member.user.avatarIcon)
                        .font(.title2)
                        .foregroundStyle(CCTheme.accentBlue)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(member.user.name)
                            .font(.subheadline.bold())
                            .foregroundStyle(CCTheme.textPrimary)
                        Text(member.role.rawValue)
                            .font(.caption)
                            .foregroundStyle(CCTheme.textSecondary)
                    }

                    Spacer()

                    Text(member.visibilityLevel.rawValue)
                        .font(.caption2)
                        .foregroundStyle(CCTheme.accentBlue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(CCTheme.lightBlue)
                        .clipShape(Capsule())
                }
                .padding(.vertical, 4)
            }
        }
        .padding(CCTheme.paddingMedium)
        .background(CCTheme.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: CCTheme.cornerRadiusMedium))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }

    // MARK: - Goals

    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Shared Goals", action: nil)

            if circle.goals.isEmpty {
                Text("No shared goals yet. Create one to get started!")
                    .font(.subheadline)
                    .foregroundStyle(CCTheme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, CCTheme.paddingLarge)
            } else {
                ForEach(circle.goals) { goal in
                    GoalProgressCard(goal: goal)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        CircleDetailView(circle: MockDataService.shared.circles[0])
    }
}
