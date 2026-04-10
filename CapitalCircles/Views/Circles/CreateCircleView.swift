import SwiftUI

struct CreateCircleView: View {
    @Environment(AppStateManager.self) private var state
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var selectedType: CircleType = .family

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: CCTheme.space7) {
                    header
                    nameField
                    typeField
                    privacyNote
                }
                .padding(.vertical, CCTheme.space5)
                .padding(.bottom, CCTheme.space9)
            }
            .background(CCTheme.canvas)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .font(.ccBody)
                        .foregroundStyle(CCTheme.ink)
                }
            }
            .overlay(alignment: .bottom) {
                createButton
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: CCTheme.space2) {
            Text("NEW CIRCLE")
                .font(.ccCaption)
                .foregroundStyle(CCTheme.slate)
                .tracking(0.5)
            Text("Invite people who\nmatter to you")
                .font(.ccLargeTitle)
                .foregroundStyle(CCTheme.ink)
        }
        .padding(.horizontal, CCTheme.space5)
    }

    private var nameField: some View {
        VStack(alignment: .leading, spacing: CCTheme.space2) {
            Text("CIRCLE NAME")
                .font(.ccCaption)
                .foregroundStyle(CCTheme.slate)
                .tracking(0.5)
            TextField("e.g. Garza Family", text: $name)
                .font(.ccHeadline)
                .foregroundStyle(CCTheme.ink)
                .padding(CCTheme.space4)
                .background(CCTheme.fog)
                .clipShape(RoundedRectangle(cornerRadius: CCTheme.radiusMedium))
        }
        .padding(.horizontal, CCTheme.space5)
    }

    private var typeField: some View {
        VStack(alignment: .leading, spacing: CCTheme.space3) {
            Text("TYPE")
                .font(.ccCaption)
                .foregroundStyle(CCTheme.slate)
                .tracking(0.5)

            VStack(spacing: 0) {
                ForEach(Array(CircleType.allCases.enumerated()), id: \.element) { index, type in
                    Button {
                        selectedType = type
                    } label: {
                        typeOption(type: type, isSelected: selectedType == type)
                    }
                    .buttonStyle(.plain)
                    if index < CircleType.allCases.count - 1 {
                        Divider().padding(.leading, 56)
                    }
                }
            }
            .background(CCTheme.fog)
            .clipShape(RoundedRectangle(cornerRadius: CCTheme.radiusMedium))
        }
        .padding(.horizontal, CCTheme.space5)
    }

    private func typeOption(type: CircleType, isSelected: Bool) -> some View {
        HStack(spacing: CCTheme.space4) {
            Image(systemName: type.icon)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(CCTheme.navy)
                .frame(width: 28, alignment: .center)

            VStack(alignment: .leading, spacing: 2) {
                Text(type.rawValue)
                    .font(.ccBody)
                    .foregroundStyle(CCTheme.ink)
                Text(typeDescription(type))
                    .font(.ccFootnote)
                    .foregroundStyle(CCTheme.slate)
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(CCTheme.navy)
            }
        }
        .padding(.horizontal, CCTheme.space4)
        .padding(.vertical, CCTheme.space4)
        .contentShape(Rectangle())
    }

    private func typeDescription(_ type: CircleType) -> String {
        switch type {
        case .family: return "Parents and kids with junior roles"
        case .roommates: return "Shared household expenses and goals"
        case .friends: return "Group goals and mutual support"
        case .couple: return "Joint planning with private finances"
        }
    }

    private var privacyNote: some View {
        HStack(alignment: .top, spacing: CCTheme.space3) {
            Image(systemName: "lock.shield")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(CCTheme.slate)
            Text("Members will only see shared goals by default. Personal finances and spending stay private unless each person chooses otherwise.")
                .font(.ccFootnote)
                .foregroundStyle(CCTheme.slate)
        }
        .padding(.horizontal, CCTheme.space5)
    }

    private var createButton: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [CCTheme.canvas.opacity(0), CCTheme.canvas],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 20)

            Button {
                _ = state.createCircle(
                    name: name,
                    type: selectedType,
                    iconName: selectedType.icon
                )
                dismiss()
            } label: {
                Text("Create circle")
            }
            .buttonStyle(CCPrimaryButtonStyle())
            .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            .opacity(name.trimmingCharacters(in: .whitespaces).isEmpty ? 0.4 : 1)
            .padding(.horizontal, CCTheme.space5)
            .padding(.bottom, CCTheme.space5)
            .background(CCTheme.canvas)
        }
    }
}
