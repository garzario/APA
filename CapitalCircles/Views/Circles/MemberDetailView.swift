import SwiftUI

/// Shows everything the current user can see about another circle member.
/// Enforces privacy rules based on role and circle type: parents can see
/// children's cards and spending, roommates and friends see only shared goals,
/// couples see each other based on their chosen visibility level.
struct MemberDetailView: View {
    @Environment(AppStateManager.self) private var state
    @Environment(\.dismiss) private var dismiss
    let member: CircleMember
    let circleId: UUID

    @State private var showRemoveAlert = false
    @State private var showNudgeSheet = false

    init(member: CircleMember, circleId: UUID) {
        self.member = member
        self.circleId = circleId
    }

    private var circle: Circle? {
        state.circles.first(where: { $0.id == circleId })
    }

    private var circleType: CircleType {
        circle?.type ?? .family
    }

    private var isCurrentUser: Bool {
        member.user.id == state.currentUser.id
    }

    private var currentUserMember: CircleMember? {
        circle?.members.first(where: { $0.user.id == state.currentUser.id })
    }

    /// Can the current user see this member's cards and spending?
    private var canSeeFinances: Bool {
        if isCurrentUser { return true }
        guard let me = currentUserMember else { return false }
        return me.role.canViewSpending(of: member.role, in: circleType)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: CCTheme.space7) {
                    header

                    if canSeeFinances {
                        monthlySpendingCard
                        cardsSection
                        activitySection
                    } else {
                        privacyCard
                    }

                    roleSection

                    if !isCurrentUser {
                        nudgeButton
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
            .sheet(isPresented: $showNudgeSheet) {
                NudgeSheet(recipient: member.user)
                    .presentationDetents([.medium])
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: CCTheme.space4) {
            CCAvatar(user: member.user, size: 72)

            VStack(alignment: .leading, spacing: 4) {
                Text(member.user.name)
                    .font(.ccTitle)
                    .foregroundStyle(CCTheme.ink)
                Text(member.role.label(for: circleType))
                    .font(.ccFootnote)
                    .foregroundStyle(CCTheme.slate)
                Text(member.user.email)
                    .font(.ccCaption)
                    .foregroundStyle(CCTheme.mist)
                    .padding(.top, 2)
            }
            Spacer()
        }
        .padding(.horizontal, CCTheme.space5)
    }

    // MARK: - Monthly Spending (visible only if allowed)

    private var monthlySpendingCard: some View {
        let total = monthlySpending
        let status = financialStatus
        let cutoff = Date(timeIntervalSinceNow: -86400 * 30)
        let txCount = member.user.transactions.filter { $0.date >= cutoff }.count

        return VStack(alignment: .leading, spacing: CCTheme.space3) {
            Text("THIS MONTH")
                .font(.ccCaption)
                .foregroundStyle(CCTheme.slate)
                .tracking(0.5)
            Text("$\(Int(total).formatted())")
                .font(.ccAmountLarge)
                .foregroundStyle(CCTheme.ink)
                .monospacedDigit()
            HStack(spacing: CCTheme.space3) {
                HStack(spacing: 4) {
                    SwiftUI.Circle()
                        .fill(status.color)
                        .frame(width: 8, height: 8)
                    Text(status.label)
                        .font(.ccFootnote.bold())
                        .foregroundStyle(status.color)
                }
                Text("•")
                    .foregroundStyle(CCTheme.mist)
                Text("\(txCount) transactions")
                    .font(.ccFootnote)
                    .foregroundStyle(CCTheme.slate)
            }
        }
        .padding(CCTheme.space5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CCTheme.cream)
        .clipShape(RoundedRectangle(cornerRadius: CCTheme.radiusMedium))
        .padding(.horizontal, CCTheme.space5)
    }

    private var monthlySpending: Double {
        let cutoff = Date(timeIntervalSinceNow: -86400 * 30)
        return member.user.transactions.filter { $0.date >= cutoff }.reduce(0.0) { $0 + $1.amount }
    }

    private var financialStatus: (label: String, color: Color) {
        let spent = monthlySpending
        if member.role == .junior {
            return spent < 800 ? ("Within allowance", CCTheme.positive) : ("Over allowance", CCTheme.red)
        }
        if spent < 4000 { return ("On track", CCTheme.positive) }
        if spent < 7000 { return ("Steady", CCTheme.navy) }
        return ("Watch", CCTheme.red)
    }

    // MARK: - Cards

    private var cardsSection: some View {
        CCSection("Cards") {
            if member.user.cards.isEmpty {
                InlineEmptyState(
                    icon: "creditcard",
                    title: "No cards yet",
                    subtitle: "\(member.user.name.components(separatedBy: " ").first ?? "They") haven't added any Capital One cards."
                )
                .padding(.horizontal, CCTheme.space5)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: CCTheme.space4) {
                        ForEach(member.user.cards) { card in
                            RealisticCardView(card: card)
                                .frame(width: 280, height: 170)
                        }
                    }
                    .padding(.horizontal, CCTheme.space5)
                }
            }
        }
    }

    // MARK: - Activity

    private var activitySection: some View {
        let cutoff = Date(timeIntervalSinceNow: -86400 * 30)
        let recent = member.user.transactions
            .filter { $0.date >= cutoff }
            .sorted { $0.date > $1.date }
            .prefix(8)

        return CCSection("Recent activity") {
            if recent.isEmpty {
                Text("No transactions in the last 30 days")
                    .font(.ccFootnote)
                    .foregroundStyle(CCTheme.slate)
                    .padding(.horizontal, CCTheme.space5)
            } else {
                VStack(spacing: 0) {
                    Divider()
                    ForEach(Array(recent.enumerated()), id: \.element.id) { index, transaction in
                        TransactionRow(transaction: transaction)
                        if index < recent.count - 1 {
                            Divider().padding(.leading, 56)
                        }
                    }
                    Divider()
                }
            }
        }
    }

    // MARK: - Privacy Card (shown when current user cannot see finances)

    private var privacyCard: some View {
        VStack(alignment: .leading, spacing: CCTheme.space3) {
            HStack(spacing: CCTheme.space3) {
                Image(systemName: "lock.shield")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(CCTheme.navy)
                    .clipShape(SwiftUI.Circle())
                Text("PRIVATE")
                    .font(.ccCaption)
                    .foregroundStyle(CCTheme.slate)
                    .tracking(0.5)
            }

            Text("\(member.user.name.components(separatedBy: " ").first ?? "They")'s finances are private")
                .font(.ccTitle)
                .foregroundStyle(CCTheme.ink)

            Text(privacyReason)
                .font(.ccFootnote)
                .foregroundStyle(CCTheme.slate)
                .lineSpacing(3)
        }
        .padding(CCTheme.space5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CCTheme.cream)
        .clipShape(RoundedRectangle(cornerRadius: CCTheme.radiusMedium))
        .padding(.horizontal, CCTheme.space5)
    }

    private var privacyReason: String {
        switch circleType {
        case .family:
            if member.role == .admin {
                return "Capital Circles keeps parents private from each other unless both opt in. You can share goals and encourage each other without opening your bank accounts."
            }
            return "In this circle, you can see shared goals and progress. Personal spending stays private."
        case .roommates:
            return "Roommate circles are for shared expenses and goals only. Personal spending stays private for everyone."
        case .friends:
            return "Friend circles are built around shared goals. Nobody sees anyone else's personal spending."
        case .couple:
            return "Your partner has not opted in to share their spending yet. Shared goals are still visible to both of you."
        }
    }

    // MARK: - Role Section

    private var roleSection: some View {
        CCSection("Role & permissions") {
            VStack(spacing: 0) {
                Divider()
                HStack(spacing: CCTheme.space4) {
                    Image(systemName: roleIcon(member.role))
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(CCTheme.navy)
                        .frame(width: 32, alignment: .center)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(member.role.label(for: circleType))
                            .font(.ccBody.bold())
                            .foregroundStyle(CCTheme.ink)
                        Text(roleDescription(member.role))
                            .font(.ccFootnote)
                            .foregroundStyle(CCTheme.slate)
                            .lineSpacing(2)
                    }
                    Spacer()
                }
                .padding(.horizontal, CCTheme.space5)
                .padding(.vertical, CCTheme.space4)
                Divider()
            }
        }
    }

    // MARK: - Nudge Button

    private var nudgeButton: some View {
        Button {
            showNudgeSheet = true
        } label: {
            HStack(spacing: CCTheme.space2) {
                Image(systemName: "hand.wave")
                    .font(.system(size: 16, weight: .medium))
                Text("Send a nudge")
            }
        }
        .buttonStyle(CCPrimaryButtonStyle())
        .padding(.horizontal, CCTheme.space5)
    }

    // MARK: - Remove Button

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
        case .admin: return "Can manage the circle and invite members"
        case .member: return "Can view and contribute to shared goals"
        case .junior: return "Limited access. Parents can see their cards and spending. They cannot see parent finances."
        }
    }
}

// MARK: - Nudge Sheet

struct NudgeSheet: View {
    @Environment(AppStateManager.self) private var state
    @Environment(\.dismiss) private var dismiss
    let recipient: User

    @State private var selectedNudge: String?

    private let nudgeOptions: [(emoji: String, text: String)] = [
        ("star", "Great job this month!"),
        ("flag.checkered", "Keep going, almost there!"),
        ("hand.thumbsup", "Proud of your progress"),
        ("heart", "Sending positive vibes"),
        ("sparkles", "You're crushing it"),
        ("cup.and.saucer", "Let's talk about money over coffee?")
    ]

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: CCTheme.space6) {
                VStack(alignment: .leading, spacing: CCTheme.space2) {
                    Text("SEND A NUDGE")
                        .font(.ccCaption)
                        .foregroundStyle(CCTheme.slate)
                        .tracking(0.5)
                    Text("Send \(recipient.name.components(separatedBy: " ").first ?? "them")\nsome encouragement")
                        .font(.ccLargeTitle)
                        .foregroundStyle(CCTheme.ink)
                        .lineSpacing(2)
                }

                VStack(spacing: CCTheme.space2) {
                    ForEach(nudgeOptions, id: \.text) { option in
                        Button {
                            selectedNudge = option.text
                        } label: {
                            HStack(spacing: CCTheme.space3) {
                                Image(systemName: option.emoji)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(CCTheme.navy)
                                    .frame(width: 32, height: 32)
                                    .background(CCTheme.fog)
                                    .clipShape(SwiftUI.Circle())
                                Text(option.text)
                                    .font(.ccBody)
                                    .foregroundStyle(CCTheme.ink)
                                Spacer()
                                if selectedNudge == option.text {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(CCTheme.navy)
                                }
                            }
                            .padding(CCTheme.space4)
                            .background(selectedNudge == option.text ? CCTheme.cream : CCTheme.canvas)
                            .overlay {
                                RoundedRectangle(cornerRadius: CCTheme.radiusMedium)
                                    .stroke(selectedNudge == option.text ? CCTheme.navy : CCTheme.hairline, lineWidth: 1)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: CCTheme.radiusMedium))
                        }
                        .buttonStyle(.plain)
                    }
                }

                Spacer()

                Button {
                    if let nudge = selectedNudge {
                        state.addNotification(
                            title: "Nudge sent to \(recipient.name.components(separatedBy: " ").first ?? "them")",
                            body: nudge,
                            icon: "hand.wave"
                        )
                        dismiss()
                    }
                } label: {
                    Text(selectedNudge == nil ? "Pick a nudge" : "Send")
                }
                .buttonStyle(CCPrimaryButtonStyle())
                .disabled(selectedNudge == nil)
                .opacity(selectedNudge == nil ? 0.4 : 1)
            }
            .padding(CCTheme.space5)
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
        }
    }
}

// MARK: - Realistic Capital One Card

struct RealisticCardView: View {
    let card: Card

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Gradient background
            LinearGradient(
                colors: [card.cardType.primaryColor, card.cardType.secondaryColor],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Subtle red swoosh in bottom right (Capital One brand)
            GeometryReader { geo in
                Path { path in
                    path.move(to: CGPoint(x: geo.size.width * 0.35, y: geo.size.height + 10))
                    path.addQuadCurve(
                        to: CGPoint(x: geo.size.width + 10, y: geo.size.height * 0.45),
                        control: CGPoint(x: geo.size.width * 0.9, y: geo.size.height + 15)
                    )
                    path.addLine(to: CGPoint(x: geo.size.width + 10, y: geo.size.height + 10))
                    path.closeSubpath()
                }
                .fill(CCTheme.red.opacity(0.85))
            }

            VStack(alignment: .leading, spacing: 0) {
                // Top row
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("CAPITAL ONE")
                            .font(.system(size: 9, weight: .bold))
                            .tracking(1)
                        Text(card.cardType.tagline.uppercased())
                            .font(.system(size: 7, weight: .semibold))
                            .tracking(0.5)
                            .opacity(0.8)
                    }
                    Spacer()
                    Image(systemName: "wave.3.right")
                        .font(.system(size: 14))
                }
                .foregroundStyle(.white)

                Spacer()

                // Chip
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#D4AF37"), Color(hex: "#9B7A2B")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 36, height: 28)
                    .overlay {
                        VStack(spacing: 2) {
                            Rectangle().frame(height: 0.5)
                            Rectangle().frame(height: 0.5)
                            Rectangle().frame(height: 0.5)
                        }
                        .foregroundStyle(.white.opacity(0.3))
                        .padding(.horizontal, 4)
                    }
                    .padding(.top, 12)

                Spacer()

                // Card number placeholder
                HStack(spacing: 10) {
                    Text("••••")
                    Text("••••")
                    Text("••••")
                    Text(card.lastFourDigits)
                }
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundStyle(.white)

                // Bottom row
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 1) {
                        Text("CARDHOLDER")
                            .font(.system(size: 6, weight: .medium))
                            .tracking(0.5)
                            .opacity(0.7)
                        Text(card.name.uppercased())
                            .font(.system(size: 11, weight: .semibold))
                            .tracking(0.5)
                    }
                    Spacer()
                    Text(card.cardType == .quicksilver || card.cardType == .platinum ? "MASTERCARD" : "VISA")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(0.5)
                        .opacity(0.9)
                }
                .foregroundStyle(.white)
                .padding(.top, 8)
            }
            .padding(16)
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.2), radius: 10, y: 6)
    }
}
