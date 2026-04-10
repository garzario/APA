import SwiftUI

struct SectionHeader: View {
    let title: String
    let action: (() -> Void)?

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundStyle(CCTheme.textPrimary)
            Spacer()
            if let action {
                Button("See All") {
                    action()
                }
                .font(.subheadline)
                .foregroundStyle(CCTheme.accentBlue)
            }
        }
    }
}
