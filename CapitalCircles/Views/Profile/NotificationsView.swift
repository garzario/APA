import SwiftUI

struct NotificationsView: View {
    @Environment(AppStateManager.self) private var state
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                if state.notifications.isEmpty {
                    emptyState
                } else {
                    list
                }
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
                ToolbarItem(placement: .principal) {
                    Text("Notifications")
                        .font(.ccHeadline)
                        .foregroundStyle(CCTheme.ink)
                }
                if !state.notifications.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            state.markAllNotificationsRead()
                        } label: {
                            Text("Mark all read")
                                .font(.ccSubhead)
                                .foregroundStyle(CCTheme.navy)
                        }
                    }
                }
            }
        }
    }

    private var list: some View {
        VStack(spacing: 0) {
            Divider()
            ForEach(Array(state.notifications.enumerated()), id: \.element.id) { index, notification in
                Button {
                    state.markNotificationRead(notification.id)
                } label: {
                    notificationRow(notification)
                }
                .buttonStyle(.plain)
                if index < state.notifications.count - 1 {
                    Divider().padding(.leading, CCTheme.space5)
                }
            }
            Divider()
        }
        .padding(.top, CCTheme.space4)
    }

    private func notificationRow(_ notification: AppNotification) -> some View {
        HStack(alignment: .top, spacing: CCTheme.space4) {
            Image(systemName: notification.icon)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(CCTheme.navy)
                .frame(width: 36, height: 36)
                .background(CCTheme.fog)
                .clipShape(SwiftUI.Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(notification.title)
                    .font(.ccBody)
                    .foregroundStyle(CCTheme.ink)
                Text(notification.body)
                    .font(.ccFootnote)
                    .foregroundStyle(CCTheme.slate)
                Text(notification.date, style: .relative)
                    .font(.ccCaption)
                    .foregroundStyle(CCTheme.mist)
                    .padding(.top, 2)
            }

            Spacer()

            if !notification.isRead {
                SwiftUI.Circle()
                    .fill(CCTheme.navy)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.horizontal, CCTheme.space5)
        .padding(.vertical, CCTheme.space4)
        .contentShape(Rectangle())
    }

    private var emptyState: some View {
        VStack(spacing: CCTheme.space4) {
            Image(systemName: "bell")
                .font(.system(size: 36, weight: .regular))
                .foregroundStyle(CCTheme.mist)
                .padding(.top, CCTheme.space9)

            Text("All caught up")
                .font(.ccHeadline)
                .foregroundStyle(CCTheme.ink)

            Text("You have no notifications right now")
                .font(.ccSubhead)
                .foregroundStyle(CCTheme.slate)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, CCTheme.space9)
    }
}
