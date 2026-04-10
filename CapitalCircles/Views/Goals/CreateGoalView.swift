import SwiftUI

struct CreateGoalView: View {
    @Environment(AppStateManager.self) private var state
    @Environment(\.dismiss) private var dismiss

    let defaultCircleId: UUID?

    @State private var title: String = ""
    @State private var iconName: String = "target"
    @State private var targetText: String = ""
    @State private var hasDeadline: Bool = false
    @State private var deadline: Date = Date(timeIntervalSinceNow: 86400 * 90)
    @State private var selectedCircleId: UUID?

    init(defaultCircleId: UUID? = nil) {
        self.defaultCircleId = defaultCircleId
        _selectedCircleId = State(initialValue: defaultCircleId)
    }

    private let iconOptions: [(String, String)] = [
        ("target", "General"),
        ("house", "Home"),
        ("car", "Car"),
        ("airplane", "Trip"),
        ("laptopcomputer", "Tech"),
        ("graduationcap", "School"),
        ("heart", "Wedding"),
        ("sun.max", "Vacation"),
        ("shield", "Safety"),
        ("gift", "Gift"),
    ]

    private var targetAmount: Double {
        Double(targetText.replacingOccurrences(of: ",", with: "")) ?? 0
    }

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty && targetAmount > 0
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: CCTheme.space7) {
                    titleHeader
                    titleField
                    amountField
                    iconField
                    deadlineField
                    circleField
                    privacyNote
                }
                .padding(.vertical, CCTheme.space5)
                .padding(.bottom, CCTheme.space9)
            }
            .background(CCTheme.canvas)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .font(.ccBody)
                        .foregroundStyle(CCTheme.ink)
                }
            }
            .overlay(alignment: .bottom) {
                createButton
            }
        }
    }

    private var titleHeader: some View {
        VStack(alignment: .leading, spacing: CCTheme.space2) {
            Text("NEW GOAL")
                .font(.ccCaption)
                .foregroundStyle(CCTheme.slate)
                .tracking(0.5)
            Text("Plan something\nworth saving for")
                .font(.ccLargeTitle)
                .foregroundStyle(CCTheme.ink)
        }
        .padding(.horizontal, CCTheme.space5)
    }

    private var titleField: some View {
        VStack(alignment: .leading, spacing: CCTheme.space2) {
            Text("WHAT ARE YOU SAVING FOR?")
                .font(.ccCaption)
                .foregroundStyle(CCTheme.slate)
                .tracking(0.5)
            TextField("e.g. Summer vacation", text: $title)
                .font(.ccHeadline)
                .foregroundStyle(CCTheme.ink)
                .padding(CCTheme.space4)
                .background(CCTheme.fog)
                .clipShape(RoundedRectangle(cornerRadius: CCTheme.radiusMedium))
        }
        .padding(.horizontal, CCTheme.space5)
    }

    private var amountField: some View {
        VStack(alignment: .leading, spacing: CCTheme.space2) {
            Text("TARGET AMOUNT")
                .font(.ccCaption)
                .foregroundStyle(CCTheme.slate)
                .tracking(0.5)
            HStack(alignment: .firstTextBaseline, spacing: CCTheme.space1) {
                Text("$")
                    .font(.ccAmount)
                    .foregroundStyle(CCTheme.slate)
                TextField("0", text: $targetText)
                    .font(.ccAmount)
                    .keyboardType(.numberPad)
                    .foregroundStyle(CCTheme.ink)
            }
            .padding(CCTheme.space4)
            .background(CCTheme.fog)
            .clipShape(RoundedRectangle(cornerRadius: CCTheme.radiusMedium))
        }
        .padding(.horizontal, CCTheme.space5)
    }

    private var iconField: some View {
        VStack(alignment: .leading, spacing: CCTheme.space3) {
            Text("ICON")
                .font(.ccCaption)
                .foregroundStyle(CCTheme.slate)
                .tracking(0.5)
                .padding(.horizontal, CCTheme.space5)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: CCTheme.space3) {
                    ForEach(iconOptions, id: \.0) { option in
                        Button {
                            iconName = option.0
                        } label: {
                            Image(systemName: option.0)
                                .font(.system(size: 18, weight: .regular))
                                .foregroundStyle(iconName == option.0 ? .white : CCTheme.ink)
                                .frame(width: 52, height: 52)
                                .background(iconName == option.0 ? CCTheme.navy : CCTheme.fog)
                                .clipShape(SwiftUI.Circle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, CCTheme.space5)
            }
        }
    }

    private var deadlineField: some View {
        VStack(alignment: .leading, spacing: CCTheme.space3) {
            Toggle(isOn: $hasDeadline.animation()) {
                Text("Set a deadline")
                    .font(.ccBody)
                    .foregroundStyle(CCTheme.ink)
            }
            .tint(CCTheme.navy)

            if hasDeadline {
                DatePicker(
                    "",
                    selection: $deadline,
                    in: Date()...,
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .labelsHidden()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, CCTheme.space5)
    }

    private var circleField: some View {
        VStack(alignment: .leading, spacing: CCTheme.space3) {
            Text("SHARE WITH")
                .font(.ccCaption)
                .foregroundStyle(CCTheme.slate)
                .tracking(0.5)

            VStack(spacing: 0) {
                Button {
                    selectedCircleId = nil
                } label: {
                    shareOption(
                        title: "Just me",
                        subtitle: "Personal goal",
                        isSelected: selectedCircleId == nil
                    )
                }
                .buttonStyle(.plain)

                ForEach(state.circles) { circle in
                    Divider().padding(.leading, CCTheme.space5)
                    Button {
                        selectedCircleId = circle.id
                    } label: {
                        shareOption(
                            title: circle.name,
                            subtitle: "\(circle.memberCount) members",
                            isSelected: selectedCircleId == circle.id
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(CCTheme.fog)
            .clipShape(RoundedRectangle(cornerRadius: CCTheme.radiusMedium))
        }
        .padding(.horizontal, CCTheme.space5)
    }

    private func shareOption(title: String, subtitle: String, isSelected: Bool) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.ccBody)
                    .foregroundStyle(CCTheme.ink)
                Text(subtitle)
                    .font(.ccFootnote)
                    .foregroundStyle(CCTheme.slate)
            }
            Spacer()
            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(CCTheme.navy)
            }
        }
        .padding(CCTheme.space4)
        .contentShape(Rectangle())
    }

    private var privacyNote: some View {
        HStack(alignment: .top, spacing: CCTheme.space3) {
            Image(systemName: "lock.shield")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(CCTheme.slate)
            Text("Shared goals only show progress, not individual accounts or balances.")
                .font(.ccFootnote)
                .foregroundStyle(CCTheme.slate)
        }
        .padding(.horizontal, CCTheme.space5)
    }

    private var createButton: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [CCTheme.canvas.opacity(0), CCTheme.canvas],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 20)

            Button {
                _ = state.createGoal(
                    title: title,
                    iconName: iconName,
                    target: targetAmount,
                    deadline: hasDeadline ? deadline : nil,
                    circleId: selectedCircleId
                )
                dismiss()
            } label: {
                Text("Create goal")
            }
            .buttonStyle(CCPrimaryButtonStyle())
            .disabled(!isValid)
            .opacity(isValid ? 1 : 0.4)
            .padding(.horizontal, CCTheme.space5)
            .padding(.bottom, CCTheme.space5)
            .background(CCTheme.canvas)
        }
    }
}
