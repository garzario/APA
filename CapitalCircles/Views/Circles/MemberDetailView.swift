import SwiftUI

struct MemberDetailView: View {
    @Environment(AppStateManager.self) private var state
    @Environment(\.dismiss) private var dismiss
    let member: CircleMember
    let circleId: UUID

    @State private var selectedVisibility: VisibilityLevel
    @State private var showRemoveAlert = false

    init(member: CircleMember, circleId: UUID) {
        self.member = member
        self.circleId = circleId
        _selectedVisibility = State(initialValue: member.visibilityLevel)
    }

    private var isCurrentUser: Bool {
        member.user.id == state.currentUser.id
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: CCTheme.space7) {
                    header
                    roleSection
                    visibilitySection
                    if !isCurrentUser {
                        removeButton
                    }
                }
                .padding(.vertical, CCTheme.space5)
                .padding(.bottom, CCTheme.space8)
            }
            .background(CCTheme.canvas)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(CCTheme.ink)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Member")
                        .font(.ccHeadline)
                        .foregroundStyle(CCTheme.ink)
                }
            }
            .alert("Remove member?", isPresented: $showRemoveAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Remove", role: .destructive) {
                    state.removeMember(member.id, from: circleId)
                    dismiss()
                }
            } message: {
                Text("\(member.user.name) will be removed from the circle. They can be invited back later.")
            }
        }
    }

    private var header: some View {
        HStack(spacing: CCTheme.space4) {
            Image(systemName: member.user.avatarIcon)
                .font(.system(size: 28, weight: .regular))
                .foregroundStyle(CCTheme.navy)
                .frame(width: 72, height: 72)
                .background(CCTheme.fog)
                .clipShape(SwiftUI.Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(member.user.name)
                    .font(.ccTitle)
                    .foregroundStyle(CCTheme.ink)
                Text(member.user.email)
                    .font(.ccFootnote)
                    .foregroundStyle(CCTheme.slate)
            }
            Spacer()
        }
        .padding(.horizontal, CCTheme.space5)
    }

    private var roleSection: some View {
        CCSection("Role") {
            VStack(spacing: 0) {
                Divider()
                HStack(spacing: CCTheme.space4) {
                    Image(systemName: roleIcon(member.role))
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(CCTheme.navy)
                        .frame(width: 28, alignment: .center)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(member.role.rawValue)
                            .font(.ccBody)
                            .foregroundStyle(CCTheme.ink)
                        Text(roleDescription(member.role))
                            .font(.ccFootnote)
                            .foregroundStyle(CCTheme.slate)
                    }
                    Spacer()
                }
                .padding(.horizontal, CCTheme.space5)
                .padding(.vertical, CCTheme.space4)
                Divider()
            }
        }
    }

    private var visibilitySection: some View {
        CCSection("What this member sees") {
            VStack(spacing: 0) {
                Divider()
                ForEach(Array(VisibilityLevel.allCases.enumerated()), id: \.element) { index, level in
                    Button {
                        if !isCurrentUser {
                            selectedVisibility = level
                            state.updateVisibility(level, for: member.id, in: circleId)
                        }
                    } label: {
                        HStack(spacing: CCTheme.space4) {
                            Image(systemName: selectedVisibility == level ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 18))
                                .foregroundStyle(selectedVisibility == level ? CCTheme.navy : CCTheme.hairline)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(level.rawValue)
                                    .font(.ccBody)
                                    .foregroundStyle(CCTheme.ink)
                                Text(level.description)
                                    .font(.ccFootnote)
                                    .foregroundStyle(CCTheme.slate)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, CCTheme.space5)
                        .padding(.vertical, CCTheme.space4)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .disabled(isCurrentUser)
                    if index < VisibilityLevel.allCases.count - 1 {
                        Divider().padding(.leading, CCTheme.space5)
                    }
                }
                Divider()
            }
        }
    }

    private var removeButton: some View {
        Button {
            showRemoveAlert = true
        } label: {
            Text("Remove from circle")
                .font(.ccBody)
                .foregroundStyle(CCTheme.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, CCTheme.space4)
        }
        .padding(.horizontal, CCTheme.space5)
    }

    private func roleIcon(_ role: MemberRole) -> String {
        switch role {
        case .admin: return "star"
        case .member: return "person"
        case .junior: return "figure.child"
        }
    }

    private func roleDescription(_ role: MemberRole) -> String {
        switch role {
        case .admin: return "Can manage circle and invite members"
        case .member: return "Can view and contribute to goals"
        case .junior: return "Limited access, cannot view parent finances"
        }
    }
}
