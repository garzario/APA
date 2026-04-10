import SwiftUI

/// A custom visual toggle that's purely display. The tap handling lives on
/// the parent button so the whole card is tappable and the toggle never
/// gets lost inside a scroll view or overlay.
struct CCSwitch: View {
    let isOn: Bool
    var width: CGFloat = 46
    var height: CGFloat = 28

    var body: some View {
        ZStack(alignment: isOn ? .trailing : .leading) {
            Capsule()
                .fill(isOn ? CCTheme.navy : CCTheme.hairline)
                .frame(width: width, height: height)
            SwiftUI.Circle()
                .fill(.white)
                .frame(width: height - 4, height: height - 4)
                .padding(2)
                .shadow(color: .black.opacity(0.15), radius: 2, y: 1)
        }
        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isOn)
    }
}
