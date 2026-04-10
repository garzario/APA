import SwiftUI

struct CreateGoalView: View {
    @Environment(AppStateManager.self) private var state
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var iconName: String = "target"
    @State private var targetText: String = ""
    @State private var hasDeadline: Bool = false
    @State private var deadline: Date = Date(timeIntervalSinceNow: 86400 * 90)
    @State private var selectedCircleId: UUID?

    private let iconOptions: [(String, String)] = [
        ("target", "Target"),
        ("house.fill", "House"),
        ("car.fill", "Car"),
        ("airplane", "Trip"),
        ("laptopcomputer", "Tech"),
        ("graduationcap.fill", "School"),
        ("heart.fill", "Wedding"),
        ("sun.max.fill", "Vacation"),
        ("shield.fill", "Emergency"),
        ("gift.fill", "Gift"),
    ]

    private var targetAmount: Double {
        Double(targetText.replacingOccurrences(of: ",", with: "")) ?? 0
    }

    private var isValid: Bool {
        !title.isEmpty && targetAmount > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Goal info") {
                    TextField("Goal title", text: $title)
                        .textInputAutocapitalization(.words)

                    HStack {
                        Text("$")
                            .foregroundStyle(CCTheme.textSecondary)
                        TextField("Target amount", text: $targetText)
                            .keyboardType(.numberPad)
                    }
                }

                Section("Icon") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(iconOptions, id: \.0) { option in
                                Button {
                                    iconName = option.0
                                } label: {
                                    Image(systemName: option.0)
                                        .font(.title3)
                                        .foregroundStyle(iconName == option.0 ? .white : CCTheme.primaryBlue)
                                        .frame(width: 48, height: 48)
                                        .background(iconName == option.0 ? CCTheme.primaryBlue : CCTheme.lightBlue)
                                        .clipShape(SwiftUI.Circle())
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }

                Section("Deadline") {
                    Toggle("Set deadline", isOn: $hasDeadline)
                    if hasDeadline {
                        DatePicker("Deadline", selection: $deadline, in: Date()..., displayedComponents: .date)
                    }
                }

                Section("Share with circle") {
                    Picker("Circle", selection: $selectedCircleId) {
                        Text("Personal goal").tag(UUID?.none)
                        ForEach(state.circles) { circle in
                            HStack {
                                Image(systemName: circle.iconName)
                                Text(circle.name)
                            }
                            .tag(Optional(circle.id))
                        }
                    }
                }

                Section {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(CCTheme.accentBlue)
                        Text("Shared goals are visible to circle members but contributions come from each person separately. No bank accounts are merged.")
                            .font(.caption)
                            .foregroundStyle(CCTheme.textSecondary)
                    }
                }
            }
            .navigationTitle("New goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        _ = state.createGoal(
                            title: title,
                            iconName: iconName,
                            target: targetAmount,
                            deadline: hasDeadline ? deadline : nil,
                            circleId: selectedCircleId
                        )
                        dismiss()
                    }
                    .bold()
                    .disabled(!isValid)
                }
            }
        }
    }
}
