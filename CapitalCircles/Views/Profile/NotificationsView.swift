import SwiftUI

struct NotificationsView: View {
    @Environment(AppStateManager.self) private var state
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if state.notifications.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "bell.slash.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(CCTheme.textSecondary.opacity(0.5))
                        Text("No notifications yet")
                            .font(.headline)
                            .foregroundStyle(CCTheme.textSecondary)
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(state.notifications) { notification in
                            HStack(alignment: .top, spacing: 14) {
                                Image(systemName: notification.icon)
                                    .font(.title3)
                                    .foregroundStyle(CCTheme.primaryBlue)
                                    .frame(width: 36, height: 36)
                                    .background(CCTheme.lightBlue)
                                    .clipShape(SwiftUI.Circle())

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(notification.title)
                                        .font(.subheadline.bold())
                                        .foregroundStyle(CCTheme.textPrimary)
                                    Text(notification.body)
                                        .font(.caption)
                                        .foregroundStyle(CCTheme.textSecondary)
                                    Text(notification.date, style: .relative)
                                        .font(.caption2)
                                        .foregroundStyle(CCTheme.textSecondary.opacity(0.7))
                                }

                                Spacer()

                                if !notification.isRead {
                                    SwiftUI.Circle()
                                        .fill(CCTheme.accentBlue)
                                        .frame(width: 8, height: 8)
                                }
                            }
                            .padding(.vertical, 6)
                            .onTapGesture {
                                state.markNotificationRead(notification.id)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                }
                if !state.notifications.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Mark all read") {
                            state.markAllNotificationsRead()
                        }
                    }
                }
            }
        }
    }
}
