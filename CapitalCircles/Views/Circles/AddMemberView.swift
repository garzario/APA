import SwiftUI

/// Member invitation flow with live backend search.
/// As the user types, the app queries the backend for matching users.
/// If none match, they can still invite by email directly.
struct AddMemberView: View {
    @Environment(AppStateManager.self) private var state
    @Environment(\.dismiss) private var dismiss
    let circleId: UUID

    @State private var searchText: String = ""
    @State private var selectedRole: MemberRole = .member
    @State private var searchResults: [APIUser] = []
    @State private var isSearching: Bool = false
    @State private var searchTask: Task<Void, Never>?

    private var circle: Circle? {
        state.circles.first(where: { $0.id == circleId })
    }

    /// Current circle member IDs so we exclude them from results
    private var existingMemberIds: Set<UUID> {
        Set(circle?.members.map { $0.user.id } ?? [])
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: CCTheme.space6) {
                    header
                    searchField
                    roleField
                    resultsSection
                    if looksLikeEmail(searchText) && !searchResults.contains(where: { $0.email == searchText.lowercased() }) {
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
            .onChange(of: searchText) { _, newValue in
                performSearch(query: newValue)
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
            if isSearching {
                ProgressView()
                    .controlSize(.small)
            } else if !searchText.isEmpty {
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
                                Text(role.label(for: circle?.type ?? .family))
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
        }
    }

    @ViewBuilder
    private var resultsSection: some View {
        if searchText.count < 2 {
            HStack(alignment: .top, spacing: CCTheme.space3) {
                Image(systemName: "info.circle")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(CCTheme.slate)
                Text("Start typing to search for people already on Capital Circles, or enter an email to send an invite.")
                    .font(.ccFootnote)
                    .foregroundStyle(CCTheme.slate)
                    .lineSpacing(3)
            }
            .padding(CCTheme.space4)
            .background(CCTheme.fog)
            .clipShape(RoundedRectangle(cornerRadius: CCTheme.radiusMedium))
            .padding(.horizontal, CCTheme.space5)
        } else if !searchResults.isEmpty {
            let filtered = searchResults.filter { !existingMemberIds.contains($0.id) }
            if !filtered.isEmpty {
                CCSection("Found on Capital Circles") {
                    VStack(spacing: 0) {
                        Divider()
                        ForEach(Array(filtered.enumerated()), id: \.element.id) { index, apiUser in
                            Button {
                                addExistingUser(apiUser)
                            } label: {
                                userRow(apiUser)
                            }
                            .buttonStyle(.plain)
                            if index < filtered.count - 1 {
                                Divider().padding(.leading, 76)
                            }
                        }
                        Divider()
                    }
                }
            }
        } else if !isSearching {
            InlineEmptyState(
                icon: "person.crop.circle.badge.questionmark",
                title: "No match on Capital Circles",
                subtitle: "You can still invite them by email below."
            )
            .padding(.horizontal, CCTheme.space5)
        }
    }

    private func userRow(_ user: APIUser) -> some View {
        HStack(spacing: CCTheme.space4) {
            Text(initials(user.name))
                .font(.ccHeadline)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(CCTheme.avatarColor(for: user.id))
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
            Text("SEND EMAIL INVITE")
                .font(.ccCaption)
                .foregroundStyle(CCTheme.slate)
                .tracking(0.5)

            Text(searchText.lowercased())
                .font(.ccBody.bold())
                .foregroundStyle(CCTheme.ink)

            Text("They will get a link to join Capital Circles and your circle.")
                .font(.ccFootnote)
                .foregroundStyle(CCTheme.slate)
                .lineSpacing(3)

            Button {
                sendEmailInvite()
            } label: {
                Text("Send invite")
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

    // MARK: - Actions

    private func performSearch(query: String) {
        searchTask?.cancel()
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard trimmed.count >= 2 else {
            searchResults = []
            isSearching = false
            return
        }

        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000) // 300ms debounce
            if Task.isCancelled { return }
            await MainActor.run { isSearching = true }
            do {
                let results = try await UserAPI.search(query: trimmed, excludeUserId: state.currentUser.id)
                if Task.isCancelled { return }
                await MainActor.run {
                    self.searchResults = results
                    self.isSearching = false
                }
            } catch {
                await MainActor.run {
                    self.searchResults = []
                    self.isSearching = false
                }
            }
        }
    }

    private func addExistingUser(_ apiUser: APIUser) {
        // Build local User and add via state manager (which also syncs to backend)
        var user = User(
            id: apiUser.id,
            name: apiUser.name,
            email: apiUser.email,
            avatarIcon: apiUser.avatarIcon,
            cards: [],
            transactions: [],
            joinedDate: apiUser.createdAt ?? Date()
        )
        user.cards = MockCardGenerator.generateCards(for: user)
        user.transactions = MockCardGenerator.generateTransactions(for: user, cards: user.cards)
        state.addMember(user, to: circleId, role: selectedRole)
        dismiss()
    }

    private func sendEmailInvite() {
        let email = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        if let circle {
            state.addNotification(
                title: "Invite sent",
                body: "\(email) was invited to join \(circle.name)",
                icon: "envelope"
            )
        }
        dismiss()
    }

    private func initials(_ name: String) -> String {
        let parts = name.split(separator: " ")
        let first = parts.first?.first.map(String.init) ?? ""
        let second = parts.dropFirst().first?.first.map(String.init) ?? ""
        return (first + second).uppercased()
    }

    private func looksLikeEmail(_ s: String) -> Bool {
        let t = s.trimmingCharacters(in: .whitespaces)
        return t.contains("@") && t.contains(".") && t.count > 5
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
}
