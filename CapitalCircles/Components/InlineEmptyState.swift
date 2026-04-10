import SwiftUI

/// A compact empty state used inline inside sections.
struct InlineEmptyState: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: CCTheme.space4) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .regular))
                .foregroundStyle(CCTheme.mist)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.ccBody)
                    .foregroundStyle(CCTheme.ink)
                Text(subtitle)
                    .font(.ccFootnote)
                    .foregroundStyle(CCTheme.slate)
            }
            Spacer()
        }
        .padding(CCTheme.space4)
        .background(CCTheme.fog)
        .clipShape(RoundedRectangle(cornerRadius: CCTheme.radiusMedium))
    }
}
