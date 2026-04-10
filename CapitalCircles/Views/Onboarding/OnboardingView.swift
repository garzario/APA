import SwiftUI

/// Multi-step onboarding that sets up the user's first circle, invites members,
/// and creates an initial goal. This is where the Capital Circles experience
/// really starts — the user ends onboarding with a real, usable hub.
struct OnboardingView: View {
    @Environment(AppState.self) private var appState
    @Environment(AppStateManager.self) private var state
    @State private var step: OnboardingStep = .welcome

    enum OnboardingStep: Int, CaseIterable {
        case welcome
        case intro
        case signIn
        case circleType
        case circleName
        case circleMembers
        case firstGoal
        case ready
    }

    // Form state
    @State private var myName: String = ""
    @State private var myEmail: String = ""
    @State private var isSigningIn: Bool = false
    @State private var signInError: String?
    @State private var selectedType: CircleType = .family
    @State private var circleName: String = ""
    @State private var invitedUsers: Set<UUID> = []
    @State private var emailInvites: [String] = []
    @State private var pendingEmail: String = ""
    @State private var goalTitle: String = ""
    @State private var goalTargetText: String = ""
    @State private var goalIcon: String = "airplane"

    var body: some View {
        VStack(spacing: 0) {
            progressBar

            ScrollView {
                VStack(alignment: .leading, spacing: CCTheme.space6) {
                    switch step {
                    case .welcome: welcomeStep
                    case .intro: introStep
                    case .signIn: signInStep
                    case .circleType: circleTypeStep
                    case .circleName: circleNameStep
                    case .circleMembers: circleMembersStep
                    case .firstGoal: firstGoalStep
                    case .ready: readyStep
                    }
                }
                .padding(.horizontal, CCTheme.space5)
                .padding(.top, CCTheme.space6)
                .padding(.bottom, CCTheme.space9)
            }

            bottomBar
        }
        .background(CCTheme.canvas)
    }

    // MARK: - Progress bar

    private var progressBar: some View {
        HStack(spacing: 4) {
            ForEach(0..<OnboardingStep.allCases.count, id: \.self) { index in
                Capsule()
                    .fill(index <= step.rawValue ? CCTheme.navy : CCTheme.hairline)
                    .frame(height: 3)
                    .animation(.easeInOut(duration: 0.2), value: step)
            }
        }
        .padding(.horizontal, CCTheme.space5)
        .padding(.top, CCTheme.space5)
    }

    // MARK: - Step 1: Welcome

    private var welcomeStep: some View {
        VStack(alignment: .leading, spacing: CCTheme.space5) {
            Spacer(minLength: CCTheme.space8)

            Text("WELCOME")
                .font(.ccCaption)
                .foregroundStyle(CCTheme.slate)
                .tracking(0.5)

            Text("Reach goals\ntogether,\nnot alone.")
                .font(.system(size: 42, weight: .bold))
                .foregroundStyle(CCTheme.ink)
                .lineSpacing(4)

            Text("Capital Circles is a new way to save with the people who matter. Create shared goals with family, friends, or roommates, without combining your accounts.")
                .font(.ccBody)
                .foregroundStyle(CCTheme.slate)
                .lineSpacing(5)
                .padding(.top, CCTheme.space3)
        }
    }

    // MARK: - Step 2: Intro

    private var introStep: some View {
        VStack(alignment: .leading, spacing: CCTheme.space7) {
            VStack(alignment: .leading, spacing: CCTheme.space3) {
                Text("HOW IT WORKS")
                    .font(.ccCaption)
                    .foregroundStyle(CCTheme.slate)
                    .tracking(0.5)
                Text("Your accounts\nstay yours")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(CCTheme.ink)
                    .lineSpacing(2)
            }
            .padding(.top, CCTheme.space4)

            VStack(alignment: .leading, spacing: CCTheme.space5) {
                principleRow(
                    number: "1",
                    title: "Create a circle",
                    body: "Invite the people you want to save with. Family, friends, roommates, or your partner."
                )
                principleRow(
                    number: "2",
                    title: "Set shared goals",
                    body: "Pick what you are saving for together. A trip, a home, an emergency fund."
                )
                principleRow(
                    number: "3",
                    title: "Track progress together",
                    body: "Everyone contributes from their own account. Nobody sees anyone else's private finances."
                )
            }
        }
    }

    private func principleRow(number: String, title: String, body: String) -> some View {
        HStack(alignment: .top, spacing: CCTheme.space4) {
            Text(number)
                .font(.ccHeadline)
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(CCTheme.navy)
                .clipShape(SwiftUI.Circle())
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.ccBody.bold())
                    .foregroundStyle(CCTheme.ink)
                Text(body)
                    .font(.ccFootnote)
                    .foregroundStyle(CCTheme.slate)
                    .lineSpacing(3)
            }
        }
    }

    // MARK: - Step 3: Sign In (name + email saved to backend)

    private var signInStep: some View {
        VStack(alignment: .leading, spacing: CCTheme.space6) {
            VStack(alignment: .leading, spacing: CCTheme.space2) {
                Text("LET'S MEET")
                    .font(.ccCaption)
                    .foregroundStyle(CCTheme.slate)
                    .tracking(0.5)
                Text("Tell us who\nyou are")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(CCTheme.ink)
                    .lineSpacing(2)
            }

            VStack(alignment: .leading, spacing: CCTheme.space2) {
                Text("YOUR NAME")
                    .font(.ccCaption)
                    .foregroundStyle(CCTheme.slate)
                    .tracking(0.5)
                TextField("e.g. Patricio Garza", text: $myName)
                    .font(.ccBody)
                    .padding(CCTheme.space4)
                    .background(CCTheme.fog)
                    .clipShape(RoundedRectangle(cornerRadius: CCTheme.radiusMedium))
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
            }

            VStack(alignment: .leading, spacing: CCTheme.space2) {
                Text("YOUR EMAIL")
                    .font(.ccCaption)
                    .foregroundStyle(CCTheme.slate)
                    .tracking(0.5)
                TextField("you@example.com", text: $myEmail)
                    .font(.ccBody)
                    .padding(CCTheme.space4)
                    .background(CCTheme.fog)
                    .clipShape(RoundedRectangle(cornerRadius: CCTheme.radiusMedium))
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }

            if let signInError {
                HStack(alignment: .top, spacing: CCTheme.space2) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(CCTheme.red)
                    Text(signInError)
                        .font(.ccFootnote)
                        .foregroundStyle(CCTheme.red)
                }
            }

            HStack(alignment: .top, spacing: CCTheme.space3) {
                Image(systemName: "lock.shield")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(CCTheme.slate)
                Text("Your info is stored securely in the Capital Circles database. You can invite people with any email and they will join with their own account.")
                    .font(.ccFootnote)
                    .foregroundStyle(CCTheme.slate)
                    .lineSpacing(3)
            }
            .padding(CCTheme.space4)
            .background(CCTheme.fog)
            .clipShape(RoundedRectangle(cornerRadius: CCTheme.radiusMedium))
        }
    }

    // MARK: - Step 4: Circle Type

    private var circleTypeStep: some View {
        VStack(alignment: .leading, spacing: CCTheme.space6) {
            VStack(alignment: .leading, spacing: CCTheme.space2) {
                Text("YOUR FIRST CIRCLE")
                    .font(.ccCaption)
                    .foregroundStyle(CCTheme.slate)
                    .tracking(0.5)
                Text("Who are you\nsaving with?")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(CCTheme.ink)
                    .lineSpacing(2)
            }

            VStack(spacing: CCTheme.space3) {
                ForEach(CircleType.allCases, id: \.self) { type in
                    Button {
                        selectedType = type
                    } label: {
                        circleTypeCard(type)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func circleTypeCard(_ type: CircleType) -> some View {
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
                Text(circleTypeDescription(type))
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

    private func circleTypeDescription(_ type: CircleType) -> String {
        switch type {
        case .family: return "Parents, kids, and close family"
        case .roommates: return "People sharing a household"
        case .friends: return "A trip, event, or group goal"
        case .couple: return "Two people planning together"
        }
    }

    // MARK: - Step 4: Circle Name

    private var circleNameStep: some View {
        VStack(alignment: .leading, spacing: CCTheme.space6) {
            VStack(alignment: .leading, spacing: CCTheme.space2) {
                Text("NAME IT")
                    .font(.ccCaption)
                    .foregroundStyle(CCTheme.slate)
                    .tracking(0.5)
                Text("What do you\ncall your circle?")
                    .font(.system(size: 34, weight: .bold))
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

    // MARK: - Step 5: Members (suggested users + email invites)

    private var circleMembersStep: some View {
        VStack(alignment: .leading, spacing: CCTheme.space6) {
            VStack(alignment: .leading, spacing: CCTheme.space2) {
                Text("INVITE PEOPLE")
                    .font(.ccCaption)
                    .foregroundStyle(CCTheme.slate)
                    .tracking(0.5)
                Text("Who's joining\nyour circle?")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(CCTheme.ink)
                    .lineSpacing(2)
            }

            // Suggested contacts (pre-existing users we can match by contacts)
            let suggested = state.allUsers.filter { $0.id != state.currentUser.id }
            if !suggested.isEmpty {
                VStack(alignment: .leading, spacing: CCTheme.space3) {
                    Text("SUGGESTED FROM YOUR CONTACTS")
                        .font(.ccCaption)
                        .foregroundStyle(CCTheme.slate)
                        .tracking(0.5)

                    VStack(spacing: CCTheme.space2) {
                        ForEach(suggested) { user in
                            Button {
                                if invitedUsers.contains(user.id) {
                                    invitedUsers.remove(user.id)
                                } else {
                                    invitedUsers.insert(user.id)
                                }
                            } label: {
                                suggestedUserRow(user)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            Text("Or invite by email")
                .font(.ccCaption)
                .foregroundStyle(CCTheme.slate)
                .tracking(0.5)
                .padding(.top, CCTheme.space2)

            // Email input
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

            // Pending invites list
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
            }

            // Skip note
            if emailInvites.isEmpty {
                HStack(alignment: .top, spacing: CCTheme.space3) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(CCTheme.slate)
                    Text("No one to invite right now? That's fine. Tap Next to continue solo and add members later from your hub.")
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

    private func suggestedUserRow(_ user: User) -> some View {
        let isSelected = invitedUsers.contains(user.id)
        return HStack(spacing: CCTheme.space3) {
            CCAvatar(user: user, size: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(user.name)
                    .font(.ccBody.bold())
                    .foregroundStyle(CCTheme.ink)
                Text(user.email)
                    .font(.ccFootnote)
                    .foregroundStyle(CCTheme.slate)
            }

            Spacer()

            ZStack {
                SwiftUI.Circle()
                    .fill(isSelected ? CCTheme.navy : CCTheme.canvas)
                    .overlay {
                        SwiftUI.Circle()
                            .stroke(isSelected ? CCTheme.navy : CCTheme.hairline, lineWidth: 2)
                    }
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .frame(width: 22, height: 22)
        }
        .padding(CCTheme.space3)
        .background(isSelected ? CCTheme.cream : CCTheme.canvas)
        .overlay {
            RoundedRectangle(cornerRadius: CCTheme.radiusMedium)
                .stroke(isSelected ? CCTheme.navy : CCTheme.hairline, lineWidth: isSelected ? 2 : 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: CCTheme.radiusMedium))
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

    // MARK: - Step 6: First Goal

    private var firstGoalStep: some View {
        VStack(alignment: .leading, spacing: CCTheme.space6) {
            VStack(alignment: .leading, spacing: CCTheme.space2) {
                Text("FIRST GOAL")
                    .font(.ccCaption)
                    .foregroundStyle(CCTheme.slate)
                    .tracking(0.5)
                Text("What are you\nsaving for?")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(CCTheme.ink)
                    .lineSpacing(2)
            }

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
                                    .font(.system(size: 20, weight: .regular))
                                    .foregroundStyle(goalIcon == icon ? .white : CCTheme.ink)
                                    .frame(width: 56, height: 56)
                                    .background(goalIcon == icon ? CCTheme.navy : CCTheme.fog)
                                    .clipShape(SwiftUI.Circle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    private let iconOptions = [
        "airplane", "house", "car", "graduationcap", "heart",
        "sun.max", "gift", "birthday.cake", "laptopcomputer", "shield"
    ]

    // MARK: - Step 7: Ready

    private var readyStep: some View {
        VStack(alignment: .leading, spacing: CCTheme.space6) {
            Spacer(minLength: CCTheme.space8)

            Text("YOU ARE SET")
                .font(.ccCaption)
                .foregroundStyle(CCTheme.slate)
                .tracking(0.5)

            Text("Welcome to\nyour hub.")
                .font(.system(size: 42, weight: .bold))
                .foregroundStyle(CCTheme.ink)
                .lineSpacing(2)

            let totalInvites = emailInvites.count + invitedUsers.count
            Text("\(circleName) is ready. \(totalInvites > 0 ? "\(totalInvites) \(totalInvites == 1 ? "person" : "people") will receive an invite" : "You can invite members anytime from your hub"). Your first goal is \(goalTitle).")
                .font(.ccBody)
                .foregroundStyle(CCTheme.slate)
                .lineSpacing(5)

            VStack(alignment: .leading, spacing: CCTheme.space4) {
                summaryRow(label: "Circle", value: circleName)
                summaryRow(label: "Type", value: selectedType.rawValue)
                summaryRow(label: "Invites", value: totalInvites > 0 ? "\(totalInvites) pending" : "None yet")
                summaryRow(label: "First goal", value: goalTitle)
                if let amount = Double(goalTargetText.replacingOccurrences(of: ",", with: "")), amount > 0 {
                    summaryRow(label: "Target", value: "$\(Int(amount).formatted())")
                }
            }
            .padding(CCTheme.space5)
            .background(CCTheme.cream)
            .clipShape(RoundedRectangle(cornerRadius: CCTheme.radiusMedium))
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

            if step == .welcome || step == .intro {
                Button {
                    skipOnboarding()
                } label: {
                    Text("Skip for now")
                        .font(.ccBody)
                        .foregroundStyle(CCTheme.slate)
                }
            } else if step.rawValue > 0 && step != .ready {
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
        .padding(.bottom, CCTheme.space6)
        .background(CCTheme.canvas)
    }

    private var primaryButtonText: String {
        switch step {
        case .welcome: return "Get started"
        case .intro: return "Continue"
        case .signIn: return isSigningIn ? "Signing in..." : "Continue"
        case .circleType: return "Next"
        case .circleName: return "Next"
        case .circleMembers: return "Next"
        case .firstGoal: return "Review"
        case .ready: return "Enter your hub"
        }
    }

    private var canAdvance: Bool {
        switch step {
        case .welcome, .intro, .circleType: return true
        case .signIn:
            let hasName = !myName.trimmingCharacters(in: .whitespaces).isEmpty
            let hasValidEmail = myEmail.contains("@") && myEmail.contains(".") && myEmail.count > 5
            return hasName && hasValidEmail && !isSigningIn
        case .circleName: return !circleName.trimmingCharacters(in: .whitespaces).isEmpty
        case .circleMembers: return true
        case .firstGoal:
            let hasTitle = !goalTitle.trimmingCharacters(in: .whitespaces).isEmpty
            let hasAmount = Double(goalTargetText.replacingOccurrences(of: ",", with: "")) ?? 0 > 0
            return hasTitle && hasAmount
        case .ready: return true
        }
    }

    private func advance() {
        if step == .ready {
            finishOnboarding()
            return
        }
        if step == .signIn {
            signIn()
            return
        }
        if let next = OnboardingStep(rawValue: step.rawValue + 1) {
            withAnimation(.easeInOut(duration: 0.25)) {
                step = next
            }
        }
    }

    private func signIn() {
        isSigningIn = true
        signInError = nil
        Task {
            await state.signIn(name: myName.trimmingCharacters(in: .whitespaces),
                               email: myEmail.trimmingCharacters(in: .whitespaces).lowercased())
            await MainActor.run {
                isSigningIn = false
                if let err = state.lastSyncError {
                    signInError = "Could not reach the server. Continuing in offline mode."
                    state.lastSyncError = nil
                }
                // Always advance (offline mode keeps local state usable)
                if let next = OnboardingStep(rawValue: step.rawValue + 1) {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        step = next
                    }
                }
            }
        }
    }

    private func back() {
        if let prev = OnboardingStep(rawValue: step.rawValue - 1) {
            withAnimation(.easeInOut(duration: 0.25)) {
                step = prev
            }
        }
    }

    private func finishOnboarding() {
        // Create the circle. We keep the seed circles (Garza Family, Team APA)
        // so the user has test data to explore after onboarding.
        let newCircle = state.createCircle(
            name: circleName,
            type: selectedType,
            iconName: selectedType.icon
        )

        // Add selected pre-existing users as real members
        for userId in invitedUsers {
            if let user = state.allUsers.first(where: { $0.id == userId }) {
                let role: MemberRole = (selectedType == .family && user.name.contains("Diego")) ? .junior : .member
                state.addMember(user, to: newCircle.id, role: role)
            }
        }

        // Create the first goal
        if let targetAmount = Double(goalTargetText.replacingOccurrences(of: ",", with: "")), targetAmount > 0 {
            _ = state.createGoal(
                title: goalTitle,
                iconName: goalIcon,
                target: targetAmount,
                deadline: nil,
                circleId: newCircle.id
            )
        }

        // Add a notification for each pending email invite so the user sees activity
        for email in emailInvites {
            state.addNotification(
                title: "Invite sent",
                body: "\(email) was invited to join \(circleName)",
                icon: "envelope"
            )
        }

        appState.completeOnboarding(userId: state.currentUser.id)
    }

    /// Skip setup entirely and go straight to the pre-seeded test data.
    /// Useful for trying the app quickly without going through the full flow.
    private func skipOnboarding() {
        appState.completeOnboarding(userId: state.currentUser.id)
    }
}
