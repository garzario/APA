import SwiftUI

/// Sheet that lets the user switch between their circles or create a new one.
/// Presented from the hub toolbar when the circle name is tapped.
struct CircleSwitcherSheet: View {
    @Environment(AppStateManager.self) private var state
    @Environment(\.dismiss) private var dismiss
    @Binding var activeCircleId: UUID?
    @State private var showCreateCircle = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: CCTheme.space6) {
                    header

                    circlesList

                    createButton
                }
                .padding(.vertical, CCTheme.space5)
            }
            .background(CCTheme.canvas)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(CCTheme.ink)
                    }
                }
            }
            .sheet(isPresented: $showCreateCircle) {
                CreateCircleView()
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: CCTheme.space2) {
            Text("SWITCH CIRCLE")
                .font(.ccCaption)
                .foregroundStyle(CCTheme.slate)
                .tracking(0.5)
            Text("Your circles")
                .font(.ccLargeTitle)
                .foregroundStyle(CCTheme.ink)
        }
        .padding(.horizontal, CCTheme.space5)
    }

    private var circlesList: some View {
        VStack(spacing: 0) {
            Divider()
            ForEach(Array(state.circles.enumerated()), id: \.element.id) { index, circle in
                Button {
                    activeCircleId = circle.id
                    dismiss()
                } label: {
                    circleRow(circle)
                }
                .buttonStyle(.plain)
                if index < state.circles.count - 1 {
                    Divider().padding(.leading, CCTheme.space5)
                }
            }
            Divider()
        }
    }

    private func circleRow(_ circle: Circle) -> some View {
        let isActive = activeCircleId == circle.id || (activeCircleId == nil && circle.type == .family)

        return HStack(spacing: CCTheme.space4) {
            Image(systemName: circle.iconName)
                .font(.system(size: 18, weight: .regular))
                .foregroundStyle(isActive ? .white : CCTheme.navy)
                .frame(width: 44, height: 44)
                .background(isActive ? CCTheme.navy : CCTheme.fog)
                .clipShape(SwiftUI.Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(circle.name)
                    .font(.ccBody)
                    .foregroundStyle(CCTheme.ink)
                Text("\(circle.memberCount) members • \(circle.goals.count) goals")
                    .font(.ccFootnote)
                    .foregroundStyle(CCTheme.slate)
            }

            Spacer()

            if isActive {
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(CCTheme.navy)
            }
        }
        .padding(.horizontal, CCTheme.space5)
        .padding(.vertical, CCTheme.space4)
        .contentShape(Rectangle())
    }

    private var createButton: some View {
        Button {
            showCreateCircle = true
        } label: {
            HStack(spacing: CCTheme.space3) {
                Image(systemName: "plus.circle")
                    .font(.system(size: 18, weight: .medium))
                Text("Create a new circle")
                    .font(.ccBody)
            }
            .foregroundStyle(CCTheme.navy)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, CCTheme.space5)
            .padding(.vertical, CCTheme.space4)
        }
        .buttonStyle(.plain)
    }
}
