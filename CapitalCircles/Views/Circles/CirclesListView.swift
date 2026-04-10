import SwiftUI

struct CirclesListView: View {
    @Environment(AppStateManager.self) private var state
    @State private var showCreateCircle = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CCTheme.paddingMedium) {
                    if state.circles.isEmpty {
                        EmptyStateCard(
                            icon: "person.3.fill",
                            title: "No circles yet",
                            message: "Create a circle with your family, friends, or roommates to start reaching goals together",
                            actionLabel: "Create circle",
                            action: { showCreateCircle = true }
                        )
                        .padding(.top, 40)
                    } else {
                        ForEach(state.circles) { circle in
                            NavigationLink(value: circle) {
                                CircleCard(circle: circle)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, CCTheme.paddingMedium)
                .padding(.top, CCTheme.paddingSmall)
            }
            .background(CCTheme.backgroundPrimary)
            .navigationTitle("Circles")
            .navigationDestination(for: Circle.self) { circle in
                CircleDetailView(circleId: circle.id)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showCreateCircle = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(CCTheme.primaryBlue)
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showCreateCircle) {
                CreateCircleView()
            }
        }
    }
}

// MARK: - Circle Card

struct CircleCard: View {
    let circle: Circle

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                Image(systemName: circle.iconName)
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(
                        LinearGradient(
                            colors: [CCTheme.primaryBlue, CCTheme.accentBlue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 4) {
                    Text(circle.name)
                        .font(.headline)
                        .foregroundStyle(CCTheme.textPrimary)
                    HStack(spacing: 8) {
                        Label("\(circle.memberCount)", systemImage: "person.fill")
                            .font(.caption)
                            .foregroundStyle(CCTheme.textSecondary)
                        Text("•")
                            .foregroundStyle(CCTheme.textSecondary.opacity(0.5))
                        Text(circle.type.rawValue)
                            .font(.caption)
                            .foregroundStyle(CCTheme.textSecondary)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(CCTheme.textSecondary.opacity(0.5))
                    .font(.caption)
            }

            if !circle.goals.isEmpty {
                Divider()
                HStack(spacing: 10) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(circle.goals.count) active goals")
                            .font(.caption2)
                            .foregroundStyle(CCTheme.textSecondary)
                        Text("\(Int(circle.totalGoalProgress * 100))% avg progress")
                            .font(.subheadline.bold())
                            .foregroundStyle(CCTheme.primaryBlue)
                    }
                    Spacer()
                    ProgressView(value: circle.totalGoalProgress)
                        .tint(CCTheme.primaryBlue)
                        .frame(maxWidth: 100)
                }
            }
        }
        .padding(CCTheme.paddingMedium)
        .background(CCTheme.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: CCTheme.cornerRadiusLarge))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 3)
    }
}
