import SwiftUI

struct CreateCircleView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var selectedType: CircleType = .family
    @State private var emoji = "👥"

    var body: some View {
        NavigationStack {
            Form {
                Section("Circle Info") {
                    TextField("Circle Name", text: $name)
                    Picker("Type", selection: $selectedType) {
                        ForEach(CircleType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                }

                Section("Privacy") {
                    // In production, this would configure detailed privacy rules
                    // per member role using Capital One's permission system
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Privacy is on by default", systemImage: "lock.shield.fill")
                            .font(.subheadline.bold())
                            .foregroundStyle(CCTheme.primaryBlue)
                        Text("Members will only see shared goals. Personal finances stay private. You can adjust visibility in settings.")
                            .font(.caption)
                            .foregroundStyle(CCTheme.textSecondary)
                    }
                    .padding(.vertical, 4)
                }

                Section("Invite Members") {
                    // Placeholder for member invitation flow
                    // In production, this would use deep links or phone contacts
                    Label("Share invite link", systemImage: "link")
                        .foregroundStyle(CCTheme.accentBlue)
                    Label("Search by email", systemImage: "magnifyingglass")
                        .foregroundStyle(CCTheme.accentBlue)
                }
            }
            .navigationTitle("New Circle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") { dismiss() }
                        .bold()
                        .disabled(name.isEmpty)
                }
            }
        }
    }
}

#Preview {
    CreateCircleView()
}
