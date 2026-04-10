import SwiftUI

struct CreateCircleView: View {
    @Environment(AppStateManager.self) private var state
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var selectedType: CircleType = .family

    private var iconForType: String {
        selectedType.icon
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Circle info") {
                    TextField("Circle name", text: $name)
                        .textInputAutocapitalization(.words)
                }

                Section("Type") {
                    ForEach(CircleType.allCases, id: \.self) { type in
                        Button {
                            selectedType = type
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: type.icon)
                                    .font(.title3)
                                    .foregroundStyle(selectedType == type ? .white : CCTheme.primaryBlue)
                                    .frame(width: 40, height: 40)
                                    .background(selectedType == type ? CCTheme.primaryBlue : CCTheme.lightBlue)
                                    .clipShape(SwiftUI.Circle())

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(type.rawValue)
                                        .font(.subheadline.bold())
                                        .foregroundStyle(CCTheme.textPrimary)
                                    Text(typeDescription(type))
                                        .font(.caption)
                                        .foregroundStyle(CCTheme.textSecondary)
                                }

                                Spacer()

                                if selectedType == type {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(CCTheme.primaryBlue)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                    }
                }

                Section {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "lock.shield.fill")
                            .foregroundStyle(CCTheme.primaryBlue)
                            .font(.title3)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Privacy first")
                                .font(.subheadline.bold())
                                .foregroundStyle(CCTheme.textPrimary)
                            Text("Members will only see shared goals by default. Personal finances and spending stay private unless you choose otherwise.")
                                .font(.caption)
                                .foregroundStyle(CCTheme.textSecondary)
                        }
                    }
                }
            }
            .navigationTitle("New Circle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        _ = state.createCircle(
                            name: name,
                            type: selectedType,
                            iconName: iconForType
                        )
                        dismiss()
                    }
                    .bold()
                    .disabled(name.isEmpty)
                }
            }
        }
    }

    private func typeDescription(_ type: CircleType) -> String {
        switch type {
        case .family: return "Parents and kids with junior roles"
        case .roommates: return "Shared household expenses and goals"
        case .friends: return "Group goals and mutual support"
        case .couple: return "Joint planning with configurable visibility"
        }
    }
}
