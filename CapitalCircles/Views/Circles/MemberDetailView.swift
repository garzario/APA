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
                VStack(spacing: CCTheme.paddingLarge) {
                    header

                    roleCard

                    visibilityCard

                    if !isCurrentUser {
                        removeButton
                    }
                }
                .padding(.horizontal, CCTheme.paddingMedium)
                .padding(.bottom, CCTheme.paddingLarge)
            }
            .background(CCTheme.backgroundPrimary)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("Remove member?", isPresented: $showRemoveAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Remove", role: .destructive) {
                    state.removeMember(member.id, from: circleId)
                    dismiss()
                }
            } message: {
                Text("This will remove \(member.user.name) from the circle. They can be re-added later.")
            }
        }
    }

    private var header: some View {
        VStack(spacing: 12) {
            Image(systemName: member.user.avatarIcon)
                .font(.system(size: 50))
                .foregroundStyle(CCTheme.primaryBlue)
                .frame(width: 100, height: 100)
                .background(CCTheme.lightBlue)
                .clipShape(SwiftUI.Circle())

            Text(member.user.name)
                .font(.title2.bold())
                .foregroundStyle(CCTheme.textPrimary)

            Text(member.user.email)
                .font(.subheadline)
                .foregroundStyle(CCTheme.textSecondary)
        }
        .padding(.top, CCTheme.paddingLarge)
    }

    private var roleCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Role")
                .font(.caption)
                .foregroundStyle(CCTheme.textSecondary)

            HStack(spacing: 12) {
                Image(systemName: roleIcon(member.role))
                    .foregroundStyle(CCTheme.primaryBlue)
                    .font(.title3)
                    .frame(width: 32, height: 32)
                    .background(CCTheme.lightBlue)
                    .clipShape(SwiftUI.Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(member.role.rawValue)
                        .font(.subheadline.bold())
                        .foregroundStyle(CCTheme.textPrimary)
                    Text(roleDescription(member.role))
                        .font(.caption)
                        .foregroundStyle(CCTheme.textSecondary)
                }
                Spacer()
            }
        }
        .padding(CCTheme.paddingMedium)
        .background(CCTheme.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: CCTheme.cornerRadiusMedium))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }

    private var visibilityCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Visibility")
                .font(.caption)
                .foregroundStyle(CCTheme.textSecondary)

            ForEach(VisibilityLevel.allCases, id: \.self) { level in
                Button {
                    if !isCurrentUser {
                        selectedVisibility = level
                        state.updateVisibility(level, for: member.id, in: circleId)
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: selectedVisibility == level ? "largecircle.fill.circle" : "circle")
                            .foregroundStyle(CCTheme.primaryBlue)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(level.rawValue)
                                .font(.subheadline.bold())
                                .foregroundStyle(CCTheme.textPrimary)
                            Text(level.description)
                                .font(.caption)
                                .foregroundStyle(CCTheme.textSecondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 6)
                }
                .buttonStyle(.plain)
                .disabled(isCurrentUser)
                if level != VisibilityLevel.allCases.last {
                    Divider()
                }
            }
        }
        .padding(CCTheme.paddingMedium)
        .background(CCTheme.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: CCTheme.cornerRadiusMedium))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }

    private var removeButton: some View {
        Button(role: .destructive) {
            showRemoveAlert = true
        } label: {
            Label("Remove from circle", systemImage: "person.fill.xmark")
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(CCTheme.errorRed.opacity(0.1))
                .foregroundStyle(CCTheme.errorRed)
                .clipShape(RoundedRectangle(cornerRadius: CCTheme.cornerRadiusMedium))
        }
    }

    private func roleIcon(_ role: MemberRole) -> String {
        switch role {
        case .admin: return "star.fill"
        case .member: return "person.fill"
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
