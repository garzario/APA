import SwiftUI

/// Member invitation flow with live search, role picker, and quick-invite cards.
/// Users can search the directory by name or email, see suggested people,
/// and invite them with a single tap.
struct AddMemberView: View {
    @Environment(AppStateManager.self) private var state
    @Environment(\.dismiss) private var dismiss
    let circleId: UUID

    @State private var searchText: String = ""
    @State private var selectedRole: MemberRole = .member
    @FocusState private var isSearchFocused: Bool

    private var circle: Circle? {
        state.circles.first(where: { $0.id == circleId })
    }

    /// Users not already in this circle
    private var availableUsers: [User] {
        guard let circle else { return [] }
        let memberIds = Set(circle.members.map { $0.user.id })
        return state.allUsers.filter { !memberIds.contains($0.id) }
    }

    /// Matches to the current search query
    private var matchingUsers: [User] {
        let trimmed = searchText.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return availableUsers }
        let query = trimmed.lowercased()
        return availableUsers.filter {
            $0.name.lowercased().contains(query) ||
            $0.email.lowercased().contains(query)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: CCTheme.space6) {
                    header
                    searchField
                    roleField
                    usersList
                    if !searchText.contains("@") && !searchText.isEmpty && matchingUsers.isEmpty {
                        inviteByEmailCard
                    }
                }
                .padding(.vertical, CCTheme.space5)
                .padding(.bottom, CCTheme.space8)
            }
            .background(CCTheme.canvas)
            .navigationTitle("Invite members")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .font(.ccBody)
                        .foregroundStyle(CCTheme.ink)
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: CCTheme.space2) {
            Text("ADD TO \(circle?.name.uppercased() ?? "CIRCLE")")
                .font(.ccCaption)
                .foregroundStyle(CCTheme.slate)
                .tracking(0.5)
            Text("Who are you\ninviting?")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(CCTheme.ink)
                .lineSpacing(2)
        }
        .padding(.horizontal, CCTheme.space5)
    }

    private var searchField: some View {
        HStack(spacing: CCTheme.space3) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(CCTheme.slate)
            TextField("Search by name or email", text: $searchText)
                .font(.ccBody)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .focused($isSearchFocused)
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(CCTheme.mist)
                }
            }
        }
        .padding(CCTheme.space4)
        .background(CCTheme.fog)
        .clipShape(RoundedRectangle(cornerRadius: CCTheme.radiusMedium))
        .padding(.horizontal, CCTheme.space5)
    }

    private var roleField: some View {
        VStack(alignment: .leading, spacing: CCTheme.space2) {
            Text("INVITE AS")
                .font(.ccCaption)
                .foregroundStyle(CCTheme.slate)
                .tracking(0.5)
                .padding(.horizontal, CCTheme.space5)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: CCTheme.space2) {
                    ForEach(availableRoles, id: \.self) { role in
                        Button {
                            selectedRole = role
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: roleIcon(role))
                                    .font(.system(size: 12, weight: .medium))
                                Text(role.rawValue)
                                    .font(.ccSubhead.weight(selectedRole == role ? .semibold : .regular))
                            }
                            .foregroundStyle(selectedRole == role ? .white : CCTheme.ink)
                            .padding(.horizontal, CCTheme.space4)
                            .padding(.vertical, CCTheme.space3)
                            .background(selectedRole == role ? CCTheme.navy : CCTheme.fog)
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, CCTheme.space5)
            }

            Text(roleDescription(selectedRole))
                .font(.ccFootnote)
                .foregroundStyle(CCTheme.slate)
                .padding(.horizontal, CCTheme.space5)
                .padding(.top, 2)
        }
    }

    @ViewBuilder
    private var usersList: some View {
        if matchingUsers.isEmpty {
            if searchText.isEmpty {
                InlineEmptyState(
                    icon: "person.crop.circle.badge.questionmark",
                    title: "Everyone is already here",
                    subtitle: "All known users are already members of this circle"
                )
                .padding(.horizontal, CCTheme.space5)
            }
        } else {
            CCSection(searchText.isEmpty ? "Suggested" : "Matches") {
                VStack(spacing: 0) {
                    Divider()
                    ForEach(Array(matchingUsers.enumerated()), id: \.element.id) { index, user in
                        Button {
                            state.addMember(user, to: circleId, role: selectedRole)
                            dismiss()
                        } label: {
                            userRow(user)
                        }
                        .buttonStyle(.plain)
                        if index < matchingUsers.count - 1 {
                            Divider().padding(.leading, 76)
                        }
                    }
                    Divider()
                }
            }
        }
    }

    private func userRow(_ user: User) -> some View {
        HStack(spacing: CCTheme.space4) {
            CCAvatar(user: user, size: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(user.name)
                    .font(.ccBody)
                    .foregroundStyle(CCTheme.ink)
                Text(user.email)
                    .font(.ccFootnote)
                    .foregroundStyle(CCTheme.slate)
            }

            Spacer()

            Text("Invite")
                .font(.ccFootnote.bold())
                .foregroundStyle(.white)
                .padding(.horizontal, CCTheme.space3)
                .padding(.vertical, 6)
                .background(CCTheme.navy)
                .clipShape(Capsule())
        }
        .padding(.horizontal, CCTheme.space5)
        .padding(.vertical, CCTheme.space4)
        .contentShape(Rectangle())
    }

    private var inviteByEmailCard: some View {
        VStack(alignment: .leading, spacing: CCTheme.space3) {
            Text("NO MATCH")
                .font(.ccCaption)
                .foregroundStyle(CCTheme.slate)
                .tracking(0.5)

            Text("We could not find \"\(searchText)\"")
                .font(.ccBody)
                .foregroundStyle(CCTheme.ink)

            Text("You can still invite them. They will get a link to join your circle and create an account.")
                .font(.ccFootnote)
                .foregroundStyle(CCTheme.slate)
                .lineSpacing(3)

            Button {
                // In production this would send an email invite.
                // For the demo we just close the sheet.
                dismiss()
            } label: {
                Text("Send an email invite")
                    .font(.ccSubhead.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, CCTheme.space5)
                    .padding(.vertical, CCTheme.space3)
                    .background(CCTheme.navy)
                    .clipShape(Capsule())
            }
            .padding(.top, CCTheme.space2)
        }
        .padding(CCTheme.space5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CCTheme.cream)
        .clipShape(RoundedRectangle(cornerRadius: CCTheme.radiusMedium))
        .padding(.horizontal, CCTheme.space5)
    }

    private var availableRoles: [MemberRole] {
        guard let circle else { return MemberRole.allCases }
        if circle.type == .family {
            return [.admin, .member, .junior]
        }
        return [.admin, .member]
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
        case .admin: return "Can manage the circle and invite more people"
        case .member: return "Can view and contribute to shared goals"
        case .junior: return "Limited access. Junior members cannot view parent finances."
        }
    }
}
