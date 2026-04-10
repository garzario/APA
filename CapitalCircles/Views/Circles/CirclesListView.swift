import SwiftUI

struct CirclesListView: View {
    @Environment(AppStateManager.self) private var state
    @State private var showCreateCircle = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CCTheme.space6) {
                header

                if state.circles.isEmpty {
                    emptyState
                } else {
                    circlesList
                }
            }
            .padding(.vertical, CCTheme.space5)
        }
        .background(CCTheme.canvas)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Circles")
                    .font(.ccHeadline)
                    .foregroundStyle(CCTheme.ink)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showCreateCircle = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(CCTheme.ink)
                }
            }
        }
        .navigationDestination(for: Circle.self) { circle in
            CircleDetailView(circleId: circle.id)
        }
        .navigationDestination(for: UUID.self) { id in
            CircleDetailView(circleId: id)
        }
        .sheet(isPresented: $showCreateCircle) {
            CreateCircleView()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: CCTheme.space2) {
            Text("YOUR GROUPS")
                .font(.ccCaption)
                .foregroundStyle(CCTheme.slate)
                .tracking(0.5)
            Text("Circles")
                .font(.ccLargeTitle)
                .foregroundStyle(CCTheme.ink)
            Text("Reach goals together without mixing accounts")
                .font(.ccSubhead)
                .foregroundStyle(CCTheme.slate)
        }
        .padding(.horizontal, CCTheme.space5)
    }

    private var circlesList: some View {
        VStack(spacing: 0) {
            Divider()
            ForEach(Array(state.circles.enumerated()), id: \.element.id) { index, circle in
                NavigationLink(value: circle.id) {
                    CircleListRow(circle: circle)
                }
                .buttonStyle(.plain)
                if index < state.circles.count - 1 {
                    Divider().padding(.leading, 56)
                }
            }
            Divider()
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: CCTheme.space5) {
            InlineEmptyState(
                icon: "person.2",
                title: "No circles yet",
                subtitle: "Create a group with family or friends to get started"
            )
            Button {
                showCreateCircle = true
            } label: {
                Text("Create a circle")
            }
            .buttonStyle(CCPrimaryButtonStyle())
        }
        .padding(.horizontal, CCTheme.space5)
    }
}
