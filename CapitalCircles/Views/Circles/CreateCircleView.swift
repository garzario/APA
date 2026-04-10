import SwiftUI

/// Multi-step flow for creating a new circle from the hub.
/// Mirrors the onboarding experience (type, name, members, first goal)
/// so users get a consistent setup whether it's their first circle or tenth.
struct CreateCircleView: View {
    @Environment(AppStateManager.self) private var state
    @Environment(\.dismiss) private var dismiss

    @State private var step: CreateCircleStep = .type
    @State private var selectedType: CircleType = .family
    @State private var circleName: String = ""
    @State private var emailInvites: [String] = []
    @State private var pendingEmail: String = ""
    @State private var addGoal: Bool = true
    @State private var goalTitle: String = ""
    @State private var goalTargetText: String = ""
    @State private var goalIcon: String = "airplane"
    @State private var shareSpending: Bool = false
    @State private var shareCategories: Bool = false
    @State private var parentsSeeChildren: Bool = true

    enum CreateCircleStep: Int, CaseIterable {
        case type
        case name
        case members
        case privacy
        case goal
        case review
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                progressBar

                ScrollView {
                    VStack(alignment: .leading, spacing: CCTheme.space6) {
                        switch step {
                        case .type: typeStep
                        case .name: nameStep
                        case .members: membersStep
                        case .privacy: privacyStep
                        case .goal: goalStep
                        case .review: reviewStep
                        }
                    }
                    .padding(.horizontal, CCTheme.space5)
                    .padding(.top, CCTheme.space5)
                    .padding(.bottom, CCTheme.space8)
                }

                bottomBar
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
        }
    }

    private var progressBar: some View {
        HStack(spacing: 4) {
            ForEach(0..<CreateCircleStep.allCases.count, id: \.self) { index in
                Capsule()
                    .fill(index <= step.rawValue ? CCTheme.navy : CCTheme.hairline)
                    .frame(height: 3)
                    .animation(.easeInOut(duration: 0.2), value: step)
            }
        }
        .padding(.horizontal, CCTheme.space5)
        .padding(.top, CCTheme.space3)
    }

    // MARK: - Step 1: Type

    private var typeStep: some View {
        VStack(alignment: .leading, spacing: CCTheme.space6) {
            VStack(alignment: .leading, spacing: CCTheme.space2) {
                Text("NEW CIRCLE")
                    .font(.ccCaption)
                    .foregroundStyle(CCTheme.slate)
                    .tracking(0.5)
                Text("Who are you\ncreating this for?")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(CCTheme.ink)
                    .lineSpacing(2)
            }

            VStack(spacing: CCTheme.space3) {
                ForEach(CircleType.allCases, id: \.self) { type in
                    Button {
                        selectedType = type
                    } label: {
                        typeCard(type)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func typeCard(_ type: CircleType) -> some View {
        let isSelected = selectedType == type

        return HStack(spacing: CCTheme.space4) {
            Image(systemName: type.icon)
                .font(.system(size: 20, weight: .regular))
                .foregroundStyle(isSelected ? .white : CCTheme.navy)
                .frame(width: 48, height: 48)
                .background(isSelected ? CCTheme.navy : CCTheme.fog)
                .clipShape(SwiftUI.Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(type.rawValue)
                    .font(.ccBody.bold())
                    .foregroundStyle(CCTheme.ink)
                Text(typeDescription(type))
                    .font(.ccFootnote)
                    .foregroundStyle(CCTheme.slate)
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(CCTheme.navy)
            }
        }
        .padding(CCTheme.space4)
        .background(isSelected ? CCTheme.cream : CCTheme.canvas)
        .overlay {
            RoundedRectangle(cornerRadius: CCTheme.radiusMedium)
                .stroke(isSelected ? CCTheme.navy : CCTheme.hairline, lineWidth: isSelected ? 2 : 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: CCTheme.radiusMedium))
    }

    private func typeDescription(_ type: CircleType) -> String {
        switch type {
        case .family: return "Parents, kids, and close family"
        case .roommates: return "People sharing a household"
        case .friends: return "A trip, event, or group goal"
        case .couple: return "Two people planning together"
        }
    }

    // MARK: - Step 2: Name

    private var nameStep: some View {
        VStack(alignment: .leading, spacing: CCTheme.space6) {
            VStack(alignment: .leading, spacing: CCTheme.space2) {
                Text("NAME IT")
                    .font(.ccCaption)
                    .foregroundStyle(CCTheme.slate)
                    .tracking(0.5)
                Text("What do you\ncall your circle?")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(CCTheme.ink)
                    .lineSpacing(2)
            }

            VStack(alignment: .leading, spacing: CCTheme.space2) {
                TextField(placeholder, text: $circleName)
                    .font(.ccTitle)
                    .foregroundStyle(CCTheme.ink)
                    .padding(CCTheme.space5)
                    .background(CCTheme.fog)
                    .clipShape(RoundedRectangle(cornerRadius: CCTheme.radiusMedium))
                    .textInputAutocapitalization(.words)

                Text("Something your members will recognize")
                    .font(.ccFootnote)
                    .foregroundStyle(CCTheme.slate)
            }
        }
    }

    private var placeholder: String {
        switch selectedType {
        case .family: return "The Garza family"
        case .roommates: return "Apartment 3B"
        case .friends: return "Cancun crew"
        case .couple: return "Us"
        }
    }

    // MARK: - Step 3: Members

    private var membersStep: some View {
        VStack(alignment: .leading, spacing: CCTheme.space6) {
            VStack(alignment: .leading, spacing: CCTheme.space2) {
                Text("INVITE")
                    .font(.ccCaption)
                    .foregroundStyle(CCTheme.slate)
                    .tracking(0.5)
                Text("Who's joining\n\(circleName)?")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(CCTheme.ink)
                    .lineSpacing(2)
            }

            Text("Add emails of the people you want to invite. You can always add more later.")
                .font(.ccFootnote)
                .foregroundStyle(CCTheme.slate)
                .lineSpacing(3)

            HStack(spacing: CCTheme.space2) {
                TextField("email@example.com", text: $pendingEmail)
                    .font(.ccBody)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(CCTheme.space4)
                    .background(CCTheme.fog)
                    .clipShape(RoundedRectangle(cornerRadius: CCTheme.radiusMedium))
                    .onSubmit { addEmail() }

                Button {
                    addEmail()
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 52, height: 52)
                        .background(isValidEmail(pendingEmail) ? CCTheme.navy : CCTheme.mist)
                        .clipShape(RoundedRectangle(cornerRadius: CCTheme.radiusMedium))
                }
                .disabled(!isValidEmail(pendingEmail))
            }

            if !emailInvites.isEmpty {
                VStack(alignment: .leading, spacing: CCTheme.space2) {
                    Text("PENDING INVITES")
                        .font(.ccCaption)
                        .foregroundStyle(CCTheme.slate)
                        .tracking(0.5)

                    VStack(spacing: CCTheme.space2) {
                        ForEach(emailInvites, id: \.self) { email in
                            HStack(spacing: CCTheme.space3) {
                                ZStack {
                                    SwiftUI.Circle()
                                        .fill(CCTheme.cream)
                                        .frame(width: 40, height: 40)
                                    Text(String(email.first?.uppercased() ?? "?"))
                                        .font(.ccHeadline)
                                        .foregroundStyle(CCTheme.navy)
                                }
                                Text(email)
                                    .font(.ccBody)
                                    .foregroundStyle(CCTheme.ink)
                                Spacer()
                                Button {
                                    emailInvites.removeAll { $0 == email }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 18))
                                        .foregroundStyle(CCTheme.mist)
                                }
                            }
                            .padding(.horizontal, CCTheme.space3)
                            .padding(.vertical, CCTheme.space2)
                            .background(CCTheme.canvas)
                            .overlay {
                                RoundedRectangle(cornerRadius: CCTheme.radiusMedium)
                                    .stroke(CCTheme.hairline, lineWidth: 1)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: CCTheme.radiusMedium))
                        }
                    }
                }
            } else {
                HStack(alignment: .top, spacing: CCTheme.space3) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(CCTheme.slate)
                    Text("Not sure yet? You can create the circle solo and invite members anytime.")
                        .font(.ccFootnote)
                        .foregroundStyle(CCTheme.slate)
                        .lineSpacing(3)
                }
                .padding(CCTheme.space4)
                .background(CCTheme.fog)
                .clipShape(RoundedRectangle(cornerRadius: CCTheme.radiusMedium))
            }
        }
    }

    private func addEmail() {
        let trimmed = pendingEmail.trimmingCharacters(in: .whitespaces).lowercased()
        if isValidEmail(trimmed) && !emailInvites.contains(trimmed) {
            emailInvites.append(trimmed)
            pendingEmail = ""
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespaces)
        return trimmed.contains("@") && trimmed.contains(".") && trimmed.count > 5
    }

    // MARK: - Step 4: Privacy

    private var privacyStep: some View {
        VStack(alignment: .leading, spacing: CCTheme.space6) {
            VStack(alignment: .leading, spacing: CCTheme.space2) {
                Text("PRIVACY")
                    .font(.ccCaption)
                    .foregroundStyle(CCTheme.slate)
                    .tracking(0.5)
                Text("What can members\nsee from each other?")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(CCTheme.ink)
                    .lineSpacing(2)
            }

            // Always visible: shared goals
            privacyBanner(
                icon: "target",
                title: "Shared goals are always visible",
                body: "Every member sees the progress of goals they are part of."
            )

            // Type-specific privacy options
            switch selectedType {
            case .family: familyPrivacyOptions
            case .couple: couplePrivacyOptions
            case .roommates: roommatesPrivacyOptions
            case .friends: friendsPrivacyOptions
            }

            // Universal note
            HStack(alignment: .top, spacing: CCTheme.space3) {
                Image(systemName: "lock.shield")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(CCTheme.slate)
                Text("You can change these settings anytime from the circle details. Members can also choose not to share more than you set here.")
                    .font(.ccFootnote)
                    .foregroundStyle(CCTheme.slate)
                    .lineSpacing(3)
            }
            .padding(CCTheme.space4)
            .background(CCTheme.fog)
            .clipShape(RoundedRectangle(cornerRadius: CCTheme.radiusMedium))
        }
    }

    private func privacyBanner(icon: String, title: String, body: String) -> some View {
        HStack(alignment: .top, spacing: CCTheme.space3) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(CCTheme.navy)
                .clipShape(SwiftUI.Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.ccBody.bold())
                    .foregroundStyle(CCTheme.ink)
                Text(body)
                    .font(.ccFootnote)
                    .foregroundStyle(CCTheme.slate)
                    .lineSpacing(2)
            }
        }
        .padding(CCTheme.space4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CCTheme.cream)
        .clipShape(RoundedRectangle(cornerRadius: CCTheme.radiusMedium))
    }

    private var familyPrivacyOptions: some View {
        VStack(alignment: .leading, spacing: CCTheme.space3) {
            Text("FAMILY SETTINGS")
                .font(.ccCaption)
                .foregroundStyle(CCTheme.slate)
                .tracking(0.5)

            privacyToggleCard(
                title: "Parents can see children's cards and spending",
                subtitle: "Recommended. Helps you guide their financial habits.",
                isOn: $parentsSeeChildren
            )

            privacyToggleCard(
                title: "Parents can see each other's spending",
                subtitle: "Off by default. Each parent stays private.",
                isOn: $shareSpending
            )

            HStack(alignment: .top, spacing: CCTheme.space3) {
                Image(systemName: "info.circle")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(CCTheme.slate)
                Text("Children never see parent finances. This is always off and cannot be changed.")
                    .font(.ccFootnote)
                    .foregroundStyle(CCTheme.slate)
                    .lineSpacing(2)
            }
            .padding(.top, CCTheme.space2)
        }
    }

    private var couplePrivacyOptions: some View {
        VStack(alignment: .leading, spacing: CCTheme.space3) {
            Text("COUPLE SETTINGS")
                .font(.ccCaption)
                .foregroundStyle(CCTheme.slate)
                .tracking(0.5)

            privacyToggleCard(
                title: "Share spending categories",
                subtitle: "Shows what you spend on (e.g. dining, travel) without exact amounts.",
                isOn: $shareCategories
            )

            privacyToggleCard(
                title: "Share full spending details",
                subtitle: "Your partner sees amounts too. Highest transparency.",
                isOn: $shareSpending
            )
        }
    }

    private var roommatesPrivacyOptions: some View {
        VStack(alignment: .leading, spacing: CCTheme.space3) {
            privacyBanner(
                icon: "house.lodge",
                title: "Roommates only share goals",
                body: "Shared expenses and goals are visible. Personal spending stays private for everyone. No exceptions."
            )
        }
    }

    private var friendsPrivacyOptions: some View {
        VStack(alignment: .leading, spacing: CCTheme.space3) {
            privacyBanner(
                icon: "person.2",
                title: "Friends only share goals",
                body: "Your friends see the progress of shared goals and nothing else. No personal spending is visible."
            )
        }
    }

    private func privacyToggleCard(title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        VStack(alignment: .leading, spacing: CCTheme.space3) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.ccBody.bold())
                        .foregroundStyle(CCTheme.ink)
                    Text(subtitle)
                        .font(.ccFootnote)
                        .foregroundStyle(CCTheme.slate)
                        .lineSpacing(2)
                }
                Spacer()
                Toggle("", isOn: isOn)
                    .labelsHidden()
                    .tint(CCTheme.navy)
            }
        }
        .padding(CCTheme.space4)
        .background(CCTheme.canvas)
        .overlay {
            RoundedRectangle(cornerRadius: CCTheme.radiusMedium)
                .stroke(CCTheme.hairline, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: CCTheme.radiusMedium))
    }

    // MARK: - Step 5: First Goal (optional)

    private var goalStep: some View {
        VStack(alignment: .leading, spacing: CCTheme.space6) {
            VStack(alignment: .leading, spacing: CCTheme.space2) {
                Text("FIRST GOAL")
                    .font(.ccCaption)
                    .foregroundStyle(CCTheme.slate)
                    .tracking(0.5)
                Text("What are you\nsaving for?")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(CCTheme.ink)
                    .lineSpacing(2)
            }

            Toggle(isOn: $addGoal.animation()) {
                Text("Add a first goal now")
                    .font(.ccBody.bold())
                    .foregroundStyle(CCTheme.ink)
            }
            .tint(CCTheme.navy)

            if addGoal {
                VStack(alignment: .leading, spacing: CCTheme.space5) {
                    VStack(alignment: .leading, spacing: CCTheme.space2) {
                        Text("GOAL NAME")
                            .font(.ccCaption)
                            .foregroundStyle(CCTheme.slate)
                            .tracking(0.5)
                        TextField("e.g. Summer vacation", text: $goalTitle)
                            .font(.ccBody)
                            .padding(CCTheme.space4)
                            .background(CCTheme.fog)
                            .clipShape(RoundedRectangle(cornerRadius: CCTheme.radiusMedium))
                            .textInputAutocapitalization(.sentences)
                    }

                    VStack(alignment: .leading, spacing: CCTheme.space2) {
                        Text("TARGET AMOUNT")
                            .font(.ccCaption)
                            .foregroundStyle(CCTheme.slate)
                            .tracking(0.5)
                        HStack(alignment: .firstTextBaseline, spacing: CCTheme.space1) {
                            Text("$")
                                .font(.ccTitle)
                                .foregroundStyle(CCTheme.slate)
                            TextField("0", text: $goalTargetText)
                                .font(.ccTitle)
                                .keyboardType(.numberPad)
                        }
                        .padding(CCTheme.space4)
                        .background(CCTheme.fog)
                        .clipShape(RoundedRectangle(cornerRadius: CCTheme.radiusMedium))
                    }

                    VStack(alignment: .leading, spacing: CCTheme.space2) {
                        Text("ICON")
                            .font(.ccCaption)
                            .foregroundStyle(CCTheme.slate)
                            .tracking(0.5)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: CCTheme.space3) {
                                ForEach(iconOptions, id: \.self) { icon in
                                    Button {
                                        goalIcon = icon
                                    } label: {
                                        Image(systemName: icon)
                                            .font(.system(size: 18, weight: .regular))
                                            .foregroundStyle(goalIcon == icon ? .white : CCTheme.ink)
                                            .frame(width: 48, height: 48)
                                            .background(goalIcon == icon ? CCTheme.navy : CCTheme.fog)
                                            .clipShape(SwiftUI.Circle())
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
            } else {
                HStack(alignment: .top, spacing: CCTheme.space3) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(CCTheme.slate)
                    Text("That's fine. You can create goals anytime from your hub.")
                        .font(.ccFootnote)
                        .foregroundStyle(CCTheme.slate)
                        .lineSpacing(3)
                }
                .padding(CCTheme.space4)
                .background(CCTheme.fog)
                .clipShape(RoundedRectangle(cornerRadius: CCTheme.radiusMedium))
            }
        }
    }

    private let iconOptions = [
        "airplane", "house", "car", "graduationcap", "heart",
        "sun.max", "gift", "laptopcomputer", "shield", "gamecontroller"
    ]

    // MARK: - Step 5: Review

    private var reviewStep: some View {
        VStack(alignment: .leading, spacing: CCTheme.space6) {
            VStack(alignment: .leading, spacing: CCTheme.space2) {
                Text("ALMOST THERE")
                    .font(.ccCaption)
                    .foregroundStyle(CCTheme.slate)
                    .tracking(0.5)
                Text("Ready to create\n\(circleName)?")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(CCTheme.ink)
                    .lineSpacing(2)
            }

            VStack(alignment: .leading, spacing: CCTheme.space4) {
                summaryRow(label: "Circle", value: circleName)
                summaryRow(label: "Type", value: selectedType.rawValue)
                summaryRow(label: "Invites", value: emailInvites.isEmpty ? "None yet" : "\(emailInvites.count) pending")
                summaryRow(label: "Privacy", value: privacySummary)
                if addGoal && !goalTitle.isEmpty {
                    summaryRow(label: "First goal", value: goalTitle)
                    if let amount = Double(goalTargetText.replacingOccurrences(of: ",", with: "")), amount > 0 {
                        summaryRow(label: "Target", value: "$\(Int(amount).formatted())")
                    }
                } else {
                    summaryRow(label: "First goal", value: "Skipped")
                }
            }
            .padding(CCTheme.space5)
            .background(CCTheme.cream)
            .clipShape(RoundedRectangle(cornerRadius: CCTheme.radiusMedium))
        }
    }

    private var privacySummary: String {
        switch selectedType {
        case .family:
            if parentsSeeChildren && shareSpending { return "Open family" }
            if parentsSeeChildren { return "Parents watch children" }
            return "Goals only"
        case .couple:
            if shareSpending { return "Full transparency" }
            if shareCategories { return "Categories shared" }
            return "Goals only"
        case .roommates, .friends:
            return "Goals only"
        }
    }

    private func summaryRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.ccFootnote)
                .foregroundStyle(CCTheme.slate)
            Spacer()
            Text(value)
                .font(.ccFootnote.bold())
                .foregroundStyle(CCTheme.ink)
        }
    }

    // MARK: - Bottom bar

    private var bottomBar: some View {
        VStack(spacing: CCTheme.space3) {
            Button {
                advance()
            } label: {
                Text(primaryButtonText)
            }
            .buttonStyle(CCPrimaryButtonStyle())
            .disabled(!canAdvance)
            .opacity(canAdvance ? 1 : 0.4)

            if step.rawValue > 0 && step != .review {
                Button {
                    back()
                } label: {
                    Text("Back")
                        .font(.ccBody)
                        .foregroundStyle(CCTheme.slate)
                }
            } else {
                Color.clear.frame(height: 22)
            }
        }
        .padding(.horizontal, CCTheme.space5)
        .padding(.bottom, CCTheme.space5)
        .background(CCTheme.canvas)
    }

    private var primaryButtonText: String {
        switch step {
        case .type: return "Next"
        case .name: return "Next"
        case .members: return "Next"
        case .privacy: return "Next"
        case .goal: return "Review"
        case .review: return "Create circle"
        }
    }

    private var canAdvance: Bool {
        switch step {
        case .type: return true
        case .name: return !circleName.trimmingCharacters(in: .whitespaces).isEmpty
        case .members: return true
        case .privacy: return true
        case .goal:
            if !addGoal { return true }
            let hasTitle = !goalTitle.trimmingCharacters(in: .whitespaces).isEmpty
            let hasAmount = Double(goalTargetText.replacingOccurrences(of: ",", with: "")) ?? 0 > 0
            return hasTitle && hasAmount
        case .review: return true
        }
    }

    private func advance() {
        if step == .review {
            create()
            return
        }
        if let next = CreateCircleStep(rawValue: step.rawValue + 1) {
            withAnimation(.easeInOut(duration: 0.25)) {
                step = next
            }
        }
    }

    private func back() {
        if let prev = CreateCircleStep(rawValue: step.rawValue - 1) {
            withAnimation(.easeInOut(duration: 0.25)) {
                step = prev
            }
        }
    }

    private func create() {
        let newCircle = state.createCircle(
            name: circleName,
            type: selectedType,
            iconName: selectedType.icon
        )

        if addGoal, !goalTitle.isEmpty,
           let targetAmount = Double(goalTargetText.replacingOccurrences(of: ",", with: "")), targetAmount > 0 {
            _ = state.createGoal(
                title: goalTitle,
                iconName: goalIcon,
                target: targetAmount,
                deadline: nil,
                circleId: newCircle.id
            )
        }

        for email in emailInvites {
            state.addNotification(
                title: "Invite sent",
                body: "\(email) was invited to join \(circleName)",
                icon: "envelope"
            )
        }

        dismiss()
    }
}
