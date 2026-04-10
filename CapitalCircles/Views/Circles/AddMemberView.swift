import SwiftUI

struct AddMemberView: View {
    @Environment(AppStateManager.self) private var state
    @Environment(\.dismiss) private var dismiss
    let circleId: UUID

    @State private var searchText: String = ""
    @State private var selectedRole: MemberRole = .member

    private var circle: Circle? {
        state.circles.first(where: { $0.id == circleId })
    }

    private var availableUsers: [User] {
        guard let circle else { return [] }
        let memberIds = Set(circle.members.map { $0.user.id })
        let available = state.allUsers.filter { !memberIds.contains($0.id) }
        if searchText.isEmpty {
            return available
        }
        return available.filter {
            $0.name.lowercased().contains(searchText.lowercased()) ||
            $0.email.lowercased().contains(searchText.lowercased())
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: CCTheme.space7) {
                    header
                    roleField
                    searchField
                    usersList
                }
                .padding(.vertical, CCTheme.space5)
                .padding(.bottom, CCTheme.space8)
            }
            .background(CCTheme.canvas)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .font(.ccBody)
                        .foregroundStyle(CCTheme.ink)
                }
                ToolbarItem(placement: .principal) {
                    Text("Add member")
                        .font(.ccHeadline)
                        .foregroundStyle(CCTheme.ink)
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: CCTheme.space2) {
            Text("INVITE")
                .font(.ccCaption)
                .foregroundStyle(CCTheme.slate)
                .tracking(0.5)
            Text("Who are you\nadding?")
                .font(.ccLargeTitle)
                .foregroundStyle(CCTheme.ink)
        }
        .padding(.horizontal, CCTheme.space5)
    }

    private var roleField: some View {
        VStack(alignment: .leading, spacing: CCTheme.space2) {
            Text("ROLE")
                .font(.ccCaption)
                .foregroundStyle(CCTheme.slate)
                .tracking(0.5)
                .padding(.horizontal, CCTheme.space5)

            HStack(spacing: CCTheme.space2) {
                ForEach(availableRoles, id: \.self) { role in
                    Button {
                        selectedRole = role
                    } label: {
                        Text(role.rawValue)
                            .font(.ccSubhead.weight(selectedRole == role ? .semibold : .regular))
                            .foregroundStyle(selectedRole == role ? .white : CCTheme.ink)
                            .padding(.horizontal, CCTheme.space4)
                            .padding(.vertical, CCTheme.space3)
                            .background(selectedRole == role ? CCTheme.navy : CCTheme.fog)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
            .padding(.horizontal, CCTheme.space5)
        }
    }

    private var searchField: some View {
        HStack(spacing: CCTheme.space3) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(CCTheme.slate)
            TextField("Search by name or email", text: $searchText)
                .font(.ccBody)
                .textInputAutocapitalization(.never)
        }
        .padding(CCTheme.space4)
        .background(CCTheme.fog)
        .clipShape(RoundedRectangle(cornerRadius: CCTheme.radiusMedium))
        .padding(.horizontal, CCTheme.space5)
    }

    @ViewBuilder
    private var usersList: some View {
        if availableUsers.isEmpty {
            InlineEmptyState(
                icon: "person.crop.circle.badge.questionmark",
                title: searchText.isEmpty ? "No users available" : "No matches",
                subtitle: searchText.isEmpty ? "Everyone is already in this circle" : "Try a different search"
            )
            .padding(.horizontal, CCTheme.space5)
        } else {
            CCSection("People") {
                VStack(spacing: 0) {
                    Divider()
                    ForEach(Array(availableUsers.enumerated()), id: \.element.id) { index, user in
                        Button {
                            state.addMember(user, to: circleId, role: selectedRole)
                            dismiss()
                        } label: {
                            userRow(user)
                        }
                        .buttonStyle(.plain)
                        if index < availableUsers.count - 1 {
                            Divider().padding(.leading, CCTheme.space5)
                        }
                    }
                    Divider()
                }
            }
        }
    }

    private func userRow(_ user: User) -> some View {
        HStack(spacing: CCTheme.space4) {
            Image(systemName: user.avatarIcon)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(CCTheme.navy)
                .frame(width: 36, height: 36)
                .background(CCTheme.fog)
                .clipShape(SwiftUI.Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(user.name)
                    .font(.ccBody)
                    .foregroundStyle(CCTheme.ink)
                Text(user.email)
                    .font(.ccFootnote)
                    .foregroundStyle(CCTheme.slate)
            }
            Spacer()
            Image(systemName: "plus")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(CCTheme.navy)
        }
        .padding(.horizontal, CCTheme.space5)
        .padding(.vertical, CCTheme.space4)
        .contentShape(Rectangle())
    }

    private var availableRoles: [MemberRole] {
        guard let circle else { return MemberRole.allCases }
        if circle.type == .family {
            return [.admin, .member, .junior]
        }
        return [.admin, .member]
    }
}
