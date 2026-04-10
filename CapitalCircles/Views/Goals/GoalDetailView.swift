import SwiftUI

struct GoalDetailView: View {
    @Environment(AppStateManager.self) private var state
    @Environment(\.dismiss) private var dismiss
    let goal: Goal

    @State private var showContribute = false
    @State private var showDeleteAlert = false

    private var currentGoal: Goal {
        state.allGoals.first(where: { $0.id == goal.id }) ?? goal
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CCTheme.paddingLarge) {
                    progressHeader
                    detailsCard
                    contributionsSection
                    actionsSection
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
            .sheet(isPresented: $showContribute) {
                ContributeSheet(goal: currentGoal)
            }
            .alert("Delete goal?", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    state.deleteGoal(goal.id)
                    dismiss()
                }
            } message: {
                Text("This will remove the goal and all its contributions.")
            }
        }
    }

    private var progressHeader: some View {
        VStack(spacing: 16) {
            Image(systemName: currentGoal.iconName)
                .font(.system(size: 50))
                .foregroundStyle(CCTheme.primaryBlue)
                .frame(width: 100, height: 100)
                .background(CCTheme.lightBlue)
                .clipShape(SwiftUI.Circle())

            Text(currentGoal.title)
                .font(.title.bold())
                .foregroundStyle(CCTheme.textPrimary)

            VStack(spacing: 8) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("$\(Int(currentGoal.currentAmount).formatted())")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(CCTheme.primaryBlue)
                    Text("of $\(Int(currentGoal.targetAmount).formatted())")
                        .font(.subheadline)
                        .foregroundStyle(CCTheme.textSecondary)
                }

                ProgressView(value: currentGoal.progressPercentage)
                    .tint(CCTheme.primaryBlue)
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                    .padding(.horizontal, 30)

                Text("\(Int(currentGoal.progressPercentage * 100))% complete")
                    .font(.caption)
                    .foregroundStyle(CCTheme.textSecondary)
            }
        }
        .padding(.top, CCTheme.paddingLarge)
    }

    private var detailsCard: some View {
        VStack(spacing: 0) {
            row(label: "Remaining", value: "$\(Int(currentGoal.remainingAmount).formatted())", icon: "arrow.right.circle.fill")
            Divider().padding(.leading, 56)
            if let deadline = currentGoal.deadline {
                row(label: "Deadline", value: deadline.formatted(date: .long, time: .omitted), icon: "calendar")
                Divider().padding(.leading, 56)
            }
            row(label: "Type", value: currentGoal.isShared ? "Shared goal" : "Personal goal", icon: currentGoal.isShared ? "person.2.fill" : "person.fill")
            if currentGoal.isShared, let circle = state.circles.first(where: { $0.id == currentGoal.circleId }) {
                Divider().padding(.leading, 56)
                row(label: "Circle", value: circle.name, icon: circle.iconName)
            }
        }
        .padding(.horizontal, CCTheme.paddingMedium)
        .background(CCTheme.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: CCTheme.cornerRadiusMedium))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }

    private var contributionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Contributions")
                .font(.headline)
                .foregroundStyle(CCTheme.textPrimary)

            if currentGoal.contributions.isEmpty {
                Text("No contributions yet. Tap contribute to start.")
                    .font(.caption)
                    .foregroundStyle(CCTheme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(CCTheme.backgroundCard)
                    .clipShape(RoundedRectangle(cornerRadius: CCTheme.cornerRadiusMedium))
            } else {
                VStack(spacing: 0) {
                    ForEach(currentGoal.contributions.sorted(by: { $0.date > $1.date })) { contribution in
                        HStack(spacing: 12) {
                            Image(systemName: "arrow.up.circle.fill")
                                .foregroundStyle(CCTheme.successGreen)
                                .font(.title3)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(contribution.userName)
                                    .font(.subheadline.bold())
                                Text(contribution.date, style: .date)
                                    .font(.caption2)
                                    .foregroundStyle(CCTheme.textSecondary)
                            }
                            Spacer()
                            Text("+$\(Int(contribution.amount).formatted())")
                                .font(.subheadline.bold())
                                .foregroundStyle(CCTheme.successGreen)
                        }
                        .padding(.vertical, 10)
                        if contribution.id != currentGoal.contributions.last?.id {
                            Divider()
                        }
                    }
                }
                .padding(.horizontal, CCTheme.paddingMedium)
                .background(CCTheme.backgroundCard)
                .clipShape(RoundedRectangle(cornerRadius: CCTheme.cornerRadiusMedium))
                .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
            }
        }
    }

    private var actionsSection: some View {
        VStack(spacing: 10) {
            Button {
                showContribute = true
            } label: {
                Label("Add contribution", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(CCTheme.primaryBlue)
                    .clipShape(RoundedRectangle(cornerRadius: CCTheme.cornerRadiusMedium))
            }

            Button {
                showDeleteAlert = true
            } label: {
                Label("Delete goal", systemImage: "trash.fill")
                    .font(.subheadline)
                    .foregroundStyle(CCTheme.errorRed)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
        }
    }

    private func row(label: String, value: String, icon: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(CCTheme.primaryBlue)
                .frame(width: 32, height: 32)
                .background(CCTheme.lightBlue)
                .clipShape(SwiftUI.Circle())
            Text(label)
                .font(.subheadline)
                .foregroundStyle(CCTheme.textSecondary)
            Spacer()
            Text(value)
                .font(.subheadline.bold())
                .foregroundStyle(CCTheme.textPrimary)
        }
        .padding(.vertical, 14)
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
            VStack(spacing: CCTheme.paddingLarge) {
                VStack(spacing: 8) {
                    Image(systemName: goal.iconName)
                        .font(.system(size: 44))
                        .foregroundStyle(CCTheme.primaryBlue)
                    Text(goal.title)
                        .font(.title3.bold())
                }
                .padding(.top, CCTheme.paddingLarge)

                VStack(spacing: 12) {
                    Text("Amount")
                        .font(.caption)
                        .foregroundStyle(CCTheme.textSecondary)
                    HStack(spacing: 8) {
                        Text("$")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundStyle(CCTheme.textPrimary)
                        TextField("0", text: $amountText)
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .keyboardType(.numberPad)
                            .focused($isAmountFocused)
                            .frame(width: 180)
                            .multilineTextAlignment(.leading)
                    }
                }
                .padding(.vertical, CCTheme.paddingLarge)
                .frame(maxWidth: .infinity)
                .background(CCTheme.backgroundCard)
                .clipShape(RoundedRectangle(cornerRadius: CCTheme.cornerRadiusLarge))
                .padding(.horizontal)

                quickAmounts

                Spacer()

                Button {
                    state.contribute(amount, to: goal.id)
                    dismiss()
                } label: {
                    Text("Contribute $\(Int(amount).formatted())")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(amount > 0 ? CCTheme.primaryBlue : CCTheme.primaryBlue.opacity(0.4))
                        .clipShape(RoundedRectangle(cornerRadius: CCTheme.cornerRadiusMedium))
                }
                .disabled(amount <= 0)
                .padding(.horizontal, CCTheme.paddingMedium)
                .padding(.bottom, CCTheme.paddingLarge)
            }
            .background(CCTheme.backgroundPrimary)
            .navigationTitle("Contribute")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear { isAmountFocused = true }
        }
    }

    private var quickAmounts: some View {
        HStack(spacing: 10) {
            ForEach([100, 500, 1000, 5000], id: \.self) { amount in
                Button {
                    amountText = String(amount)
                } label: {
                    Text("$\(amount)")
                        .font(.subheadline.bold())
                        .foregroundStyle(CCTheme.primaryBlue)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(CCTheme.lightBlue)
                        .clipShape(Capsule())
                }
            }
        }
    }
}
