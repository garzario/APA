import SwiftUI

struct CirclesListView: View {
    private let data = MockDataService.shared
    @State private var showCreateCircle = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CCTheme.paddingMedium) {
                    ForEach(data.circles) { circle in
                        NavigationLink(value: circle) {
                            CircleCard(circle: circle)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, CCTheme.paddingMedium)
                .padding(.top, CCTheme.paddingSmall)
            }
            .background(CCTheme.backgroundPrimary)
            .navigationTitle("Circles")
            .navigationDestination(for: Circle.self) { circle in
                CircleDetailView(circle: circle)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showCreateCircle = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(CCTheme.primaryBlue)
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
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: circle.iconName)
                    .font(.title2)
                    .foregroundStyle(CCTheme.primaryBlue)
                VStack(alignment: .leading, spacing: 2) {
                    Text(circle.name)
                        .font(.headline)
                        .foregroundStyle(CCTheme.textPrimary)
                    Text("\(circle.memberCount) members")
                        .font(.caption)
                        .foregroundStyle(CCTheme.textSecondary)
                }
                Spacer()
                Image(systemName: circle.type.icon)
                    .foregroundStyle(CCTheme.accentBlue)
            }

            if !circle.goals.isEmpty {
                Divider()
                HStack {
                    Text("\(circle.goals.count) active goals")
                        .font(.caption)
                        .foregroundStyle(CCTheme.textSecondary)
                    Spacer()
                    Text("\(Int(circle.totalGoalProgress * 100))% avg progress")
                        .font(.caption.bold())
                        .foregroundStyle(CCTheme.primaryBlue)
                }
            }
        }
        .padding(CCTheme.paddingMedium)
        .background(CCTheme.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: CCTheme.cornerRadiusMedium))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }
}

#Preview {
    CirclesListView()
}
