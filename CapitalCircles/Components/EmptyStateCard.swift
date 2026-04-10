import SwiftUI

struct EmptyStateCard: View {
    let icon: String
    let title: String
    let message: String
    var actionLabel: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 36))
                .foregroundStyle(CCTheme.accentBlue)
                .frame(width: 72, height: 72)
                .background(CCTheme.lightBlue)
                .clipShape(SwiftUI.Circle())

            Text(title)
                .font(.headline)
                .foregroundStyle(CCTheme.textPrimary)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(CCTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            if let actionLabel, let action {
                Button(action: action) {
                    Text(actionLabel)
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(CCTheme.primaryBlue)
                        .clipShape(Capsule())
                }
                .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .padding(.horizontal, CCTheme.paddingLarge)
        .background(CCTheme.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: CCTheme.cornerRadiusMedium))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }
}
