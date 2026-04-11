import SwiftUI

struct GoalDetailView: View {
    @Environment(AppStateManager.self) private var state
    @Environment(\.dismiss) private var dismiss
    let goal: Goal

    @State private var showContribute = false
    @State private var showDeleteAlert = false

    var body: some View {
        // Read the latest goal directly from state every time the body
        // re-evaluates so contributions update in real time.
        let latest = state.allGoals.first(where: { $0.id == goal.id }) ?? goal

        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: CCTheme.space7) {
                    heroSection(latest)
                    detailsSection(latest)
                    contributionsSection(latest)
                    dangerZone
                }
                .padding(.vertical, CCTheme.space5)
                .padding(.bottom, CCTheme.space9)
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
            .overlay(alignment: .bottom) {
                contributeButton
            }
            .sheet(isPresented: $showContribute) {
                ContributeSheet(goal: latest)
            }
            .alert("Delete goal?", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    state.deleteGoal(goal.id)
                    dismiss()
                }
            } message: {
                Text("This will remove the goal and all of its contributions.")
            }
        }
    }

    // MARK: - Hero

    private func heroSection(_ currentGoal: Goal) -> some View {
        VStack(alignment: .leading, spacing: CCTheme.space4) {
            Text(subtitle(for: currentGoal).uppercased())
                .font(.ccCaption)
                .foregroundStyle(CCTheme.slate)
                .tracking(0.5)

            Text(currentGoal.title)
                .font(.ccLargeTitle)
                .foregroundStyle(CCTheme.ink)

            HStack(alignment: .firstTextBaseline, spacing: CCTheme.space2) {
                Text("$\(Int(currentGoal.currentAmount).formatted())")
                    .font(.ccAmountLarge)
                    .foregroundStyle(CCTheme.ink)
                    .monospacedDigit()
                Text("of $\(Int(currentGoal.targetAmount).formatted())")
                    .font(.ccBody)
                    .foregroundStyle(CCTheme.slate)
                    .monospacedDigit()
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(CCTheme.hairline)
                        .frame(height: 6)
                    Capsule()
                        .fill(CCTheme.navy)
                        .frame(width: geo.size.width * currentGoal.progressPercentage, height: 6)
                }
            }
            .frame(height: 6)
            .animation(.easeInOut(duration: 0.3), value: currentGoal.progressPercentage)

            HStack(spacing: CCTheme.space4) {
                Text("\(Int(currentGoal.progressPercentage * 100))% complete")
                    .font(.ccFootnote)
                    .foregroundStyle(CCTheme.slate)
                Spacer()
                Text("$\(Int(currentGoal.remainingAmount).formatted()) to go")
                    .font(.ccFootnote)
                    .foregroundStyle(CCTheme.slate)
                    .monospacedDigit()
            }
        }
        .padding(.horizontal, CCTheme.space5)
    }

    private func subtitle(for currentGoal: Goal) -> String {
        if currentGoal.isShared {
            if let circle = state.circles.first(where: { $0.id == currentGoal.circleId }) {
                return "\(circle.name) • Shared"
            }
            return "Shared goal"
        }
        return "Personal goal"
    }

    // MARK: - Details

    private func detailsSection(_ currentGoal: Goal) -> some View {
        CCSection("Details") {
            VStack(spacing: 0) {
                Divider()
                if let deadline = currentGoal.deadline {
                    detailRow(label: "Deadline", value: deadline.formatted(date: .long, time: .omitted))
                    Divider().padding(.leading, CCTheme.space5)
                }
                detailRow(label: "Remaining", value: "$\(Int(currentGoal.remainingAmount).formatted())")
                Divider().padding(.leading, CCTheme.space5)
                detailRow(label: "Type", value: currentGoal.isShared ? "Shared" : "Personal")
                if currentGoal.isShared, let circle = state.circles.first(where: { $0.id == currentGoal.circleId }) {
                    Divider().padding(.leading, CCTheme.space5)
                    detailRow(label: "Circle", value: circle.name)
                }
                Divider()
            }
        }
    }

    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.ccBody)
                .foregroundStyle(CCTheme.slate)
            Spacer()
            Text(value)
                .font(.ccBody)
                .foregroundStyle(CCTheme.ink)
                .monospacedDigit()
        }
        .padding(.horizontal, CCTheme.space5)
        .padding(.vertical, CCTheme.space4)
    }

    // MARK: - Contributions

    private func contributionsSection(_ currentGoal: Goal) -> some View {
        CCSection("Contributions") {
            if currentGoal.contributions.isEmpty {
                InlineEmptyState(
                    icon: "plus.circle",
                    title: "No contributions yet",
                    subtitle: "Tap \"Contribute\" below to add the first one"
                )
                .padding(.horizontal, CCTheme.space5)
            } else {
                VStack(spacing: 0) {
                    Divider()
                    let sorted = currentGoal.contributions.sorted(by: { $0.date > $1.date })
                    ForEach(Array(sorted.enumerated()), id: \.element.id) { index, contribution in
                        contributionRow(contribution)
                        if index < sorted.count - 1 {
                            Divider().padding(.leading, CCTheme.space5)
                        }
                    }
                    Divider()
                }
            }
        }
    }

    private func contributionRow(_ contribution: Contribution) -> some View {
        HStack(spacing: CCTheme.space4) {
            VStack(alignment: .leading, spacing: 2) {
                Text(contribution.userName)
                    .font(.ccBody)
                    .foregroundStyle(CCTheme.ink)
                Text(contribution.date, style: .date)
                    .font(.ccFootnote)
                    .foregroundStyle(CCTheme.slate)
            }
            Spacer()
            Text("+$\(Int(contribution.amount).formatted())")
                .font(.ccBody)
                .foregroundStyle(CCTheme.positive)
                .monospacedDigit()
        }
        .padding(.horizontal, CCTheme.space5)
        .padding(.vertical, CCTheme.space4)
    }

    // MARK: - Danger Zone

    private var dangerZone: some View {
        Button {
            showDeleteAlert = true
        } label: {
            Text("Delete goal")
                .font(.ccSubhead)
                .foregroundStyle(CCTheme.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, CCTheme.space4)
        }
        .padding(.horizontal, CCTheme.space5)
    }

    // MARK: - Contribute Button

    private var contributeButton: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [CCTheme.canvas.opacity(0), CCTheme.canvas],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 20)

            Button {
                showContribute = true
            } label: {
                Text("Contribute")
            }
            .buttonStyle(CCPrimaryButtonStyle())
            .padding(.horizontal, CCTheme.space5)
            .padding(.bottom, CCTheme.space5)
            .background(CCTheme.canvas)
        }
    }
}

// MARK: - Contribute Sheet

struct ContributeSheet: View {
    @Environment(AppStateManager.self) private var state
    @Environment(\.dismiss) private var dismiss
    let goal: Goal

    @State private var amountText: String = ""
    @FocusState private var isAmountFocused: Bool

    private var amount: Double {
        Double(amountText.replacingOccurrences(of: ",", with: "")) ?? 0
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: CCTheme.space7) {
                VStack(alignment: .leading, spacing: CCTheme.space2) {
                    Text("CONTRIBUTE TO")
                        .font(.ccCaption)
                        .foregroundStyle(CCTheme.slate)
                        .tracking(0.5)
                    Text(goal.title)
                        .font(.ccLargeTitle)
                        .foregroundStyle(CCTheme.ink)
                }
                .padding(.horizontal, CCTheme.space5)
                .padding(.top, CCTheme.space5)

                VStack(alignment: .leading, spacing: CCTheme.space3) {
                    Text("AMOUNT")
                        .font(.ccCaption)
                        .foregroundStyle(CCTheme.slate)
                        .tracking(0.5)

                    HStack(alignment: .firstTextBaseline, spacing: CCTheme.space1) {
                        Text("$")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(CCTheme.slate)
                        TextField("0", text: $amountText)
                            .font(.system(size: 60, weight: .bold, design: .rounded))
                            .keyboardType(.numberPad)
                            .focused($isAmountFocused)
                            .foregroundStyle(CCTheme.ink)
                    }

                    Divider()

                    HStack(spacing: CCTheme.space2) {
                        ForEach([100, 500, 1000, 5000], id: \.self) { quickAmount in
                            Button {
                                amountText = String(quickAmount)
                            } label: {
                                Text("$\(quickAmount)")
                                    .font(.ccSubhead)
                                    .foregroundStyle(CCTheme.ink)
                                    .padding(.horizontal, CCTheme.space4)
                                    .padding(.vertical, CCTheme.space2)
                                    .background(CCTheme.fog)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.top, CCTheme.space3)
                }
                .padding(.horizontal, CCTheme.space5)

                Spacer()

                Button {
                    state.contribute(amount, to: goal.id)
                    dismiss()
                } label: {
                    Text(amount > 0 ? "Contribute $\(Int(amount).formatted())" : "Enter an amount")
                }
                .buttonStyle(CCPrimaryButtonStyle())
                .disabled(amount <= 0)
                .padding(.horizontal, CCTheme.space5)
                .padding(.bottom, CCTheme.space5)
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
            .onAppear { isAmountFocused = true }
        }
    }
}
