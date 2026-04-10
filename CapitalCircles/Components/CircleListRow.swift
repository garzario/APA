import SwiftUI

struct CircleListRow: View {
    let circle: Circle

    var body: some View {
        HStack(spacing: CCTheme.space4) {
            Image(systemName: circle.iconName)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(CCTheme.navy)
                .frame(width: 36, height: 36)
                .background(CCTheme.fog)
                .clipShape(SwiftUI.Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(circle.name)
                    .font(.ccBody)
                    .foregroundStyle(CCTheme.ink)
                Text("\(circle.memberCount) members \u{2022} \(circle.goals.count) goals")
                    .font(.ccFootnote)
                    .foregroundStyle(CCTheme.slate)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(CCTheme.mist)
        }
        .padding(.horizontal, CCTheme.space5)
        .padding(.vertical, CCTheme.space4)
        .contentShape(Rectangle())
    }
}
