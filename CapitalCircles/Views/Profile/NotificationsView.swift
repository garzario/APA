import SwiftUI

struct NotificationsView: View {
    @Environment(AppStateManager.self) private var state
    @Environment(\.dismiss) private var dismiss
    @State private var selectedNotification: AppNotification?

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
            .navigationTitle("Notifications")
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
            .sheet(item: $selectedNotification) { notification in
                NotificationDetailSheet(notification: notification)
                    .presentationDetents([.medium])
            }
        }
    }

    private var list: some View {
        VStack(spacing: 0) {
            Divider()
            ForEach(Array(state.notifications.enumerated()), id: \.element.id) { index, notification in
                Button {
                    state.markNotificationRead(notification.id)
                    selectedNotification = notification
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
                    .lineLimit(2)
                Text(relativeTime(notification.date))
                    .font(.ccCaption)
                    .foregroundStyle(CCTheme.mist)
                    .padding(.top, 2)
            }

            Spacer()

            if !notification.isRead {
                SwiftUI.Circle()
                    .fill(CCTheme.red)
                    .frame(width: 8, height: 8)
                    .padding(.top, 8)
            }
        }
        .padding(.horizontal, CCTheme.space5)
        .padding(.vertical, CCTheme.space4)
        .contentShape(Rectangle())
    }

    private func relativeTime(_ date: Date) -> String {
        let now = Date()
        let interval = now.timeIntervalSince(date)
        let minutes = Int(interval / 60)
        let hours = Int(interval / 3600)
        let days = Int(interval / 86400)

        if minutes < 1 { return "Just now" }
        if minutes < 60 { return "\(minutes)m ago" }
        if hours < 24 { return "\(hours)h ago" }
        if days < 7 { return "\(days)d ago" }
        return date.formatted(.dateTime.month(.abbreviated).day())
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

// MARK: - Notification Detail Sheet

struct NotificationDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    let notification: AppNotification

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: CCTheme.space6) {
                    header

                    Text(notification.body)
                        .font(.ccBody)
                        .foregroundStyle(CCTheme.ink)
                        .lineSpacing(4)

                    HStack {
                        Text("Received")
                            .font(.ccFootnote)
                            .foregroundStyle(CCTheme.slate)
                        Spacer()
                        Text(notification.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.ccFootnote)
                            .foregroundStyle(CCTheme.slate)
                    }
                    .padding(.top, CCTheme.space4)
                }
                .padding(CCTheme.space5)
                .padding(.bottom, CCTheme.space5)
            }
            .background(CCTheme.canvas)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(CCTheme.ink)
                    }
                }
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: CCTheme.space4) {
            Image(systemName: notification.icon)
                .font(.system(size: 22, weight: .regular))
                .foregroundStyle(CCTheme.navy)
                .frame(width: 52, height: 52)
                .background(CCTheme.fog)
                .clipShape(SwiftUI.Circle())

            Text(notification.title)
                .font(.ccTitle)
                .foregroundStyle(CCTheme.ink)
            Spacer()
        }
    }
}
