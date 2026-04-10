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
            VStack(spacing: 0) {
                // Role picker
                VStack(alignment: .leading, spacing: 10) {
                    Text("Role")
                        .font(.caption)
                        .foregroundStyle(CCTheme.textSecondary)
                        .padding(.horizontal, CCTheme.paddingMedium)

                    Picker("Role", selection: $selectedRole) {
                        ForEach(availableRoles, id: \.self) { role in
                            Text(role.rawValue).tag(role)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, CCTheme.paddingMedium)
                }
                .padding(.vertical, CCTheme.paddingMedium)
                .background(CCTheme.backgroundCard)

                List {
                    if availableUsers.isEmpty {
                        Text(searchText.isEmpty ? "No users available to add" : "No users match your search")
                            .font(.subheadline)
                            .foregroundStyle(CCTheme.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        ForEach(availableUsers) { user in
                            Button {
                                state.addMember(user, to: circleId, role: selectedRole)
                                dismiss()
                            } label: {
                                HStack(spacing: 14) {
                                    Image(systemName: user.avatarIcon)
                                        .font(.title2)
                                        .foregroundStyle(CCTheme.primaryBlue)
                                        .frame(width: 40, height: 40)
                                        .background(CCTheme.lightBlue)
                                        .clipShape(SwiftUI.Circle())
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(user.name)
                                            .font(.subheadline.bold())
                                            .foregroundStyle(CCTheme.textPrimary)
                                        Text(user.email)
                                            .font(.caption)
                                            .foregroundStyle(CCTheme.textSecondary)
                                    }
                                    Spacer()
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundStyle(CCTheme.primaryBlue)
                                }
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .searchable(text: $searchText, prompt: "Search by name or email")
            }
            .navigationTitle("Add member")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private var availableRoles: [MemberRole] {
        guard let circle else { return MemberRole.allCases }
        if circle.type == .family {
            return [.admin, .member, .junior]
        }
        return [.admin, .member]
    }
}
