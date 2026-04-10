import SwiftUI

/// Capital Circles design system.
/// Built on Capital One's brand foundation: navy, red accent, cream surfaces,
/// editorial typography, generous whitespace, minimal decoration.
enum CCTheme {

    // MARK: - Brand

    /// Capital One navy (primary brand)
    static let navy = Color(hex: "#003057")

    /// Capital One red (iconic swoosh color, used for alerts and accents)
    static let red = Color(hex: "#D03027")

    /// Deeper red for pressed states
    static let redDark = Color(hex: "#A91D1A")

    /// Ink, for headlines
    static let ink = Color(hex: "#0A0E17")

    /// Secondary text
    static let slate = Color(hex: "#5C6773")

    /// Tertiary text
    static let mist = Color(hex: "#9AA4B2")

    /// Hairline borders
    static let hairline = Color(hex: "#E6E9EE")

    /// White canvas
    static let canvas = Color(hex: "#FFFFFF")

    /// Warm cream surface layer (for sections)
    static let cream = Color(hex: "#FAF7F2")

    /// Light gray fog
    static let fog = Color(hex: "#F5F6F8")

    // MARK: - Accents

    /// Warm gold for milestones and celebrations
    static let gold = Color(hex: "#B8860B")

    /// Fresh green for positive
    static let positive = Color(hex: "#1B7F3B")

    /// Warm orange for caution
    static let caution = Color(hex: "#B8690E")

    /// Error red
    static let danger = Color(hex: "#D03027")

    // MARK: - Member avatar palette (warm, human)

    static let avatarColors: [Color] = [
        Color(hex: "#E9704A"), // coral
        Color(hex: "#3B7A57"), // sage
        Color(hex: "#8B6F47"), // mocha
        Color(hex: "#4A6FA5"), // slate blue
        Color(hex: "#B8860B"), // gold
        Color(hex: "#9B4D7A"), // mauve
    ]

    static func avatarColor(for id: UUID) -> Color {
        let index = abs(id.hashValue) % avatarColors.count
        return avatarColors[index]
    }

    // MARK: - Spacing scale

    static let space1: CGFloat = 4
    static let space2: CGFloat = 8
    static let space3: CGFloat = 12
    static let space4: CGFloat = 16
    static let space5: CGFloat = 20
    static let space6: CGFloat = 24
    static let space7: CGFloat = 32
    static let space8: CGFloat = 40
    static let space9: CGFloat = 56

    // MARK: - Radius

    static let radiusSmall: CGFloat = 10
    static let radiusMedium: CGFloat = 14
    static let radiusLarge: CGFloat = 20
    static let radiusPill: CGFloat = 999
}

// MARK: - Typography

extension Font {
    static let ccDisplay = Font.system(size: 42, weight: .bold, design: .default)
    static let ccLargeTitle = Font.system(size: 30, weight: .bold, design: .default)
    static let ccTitle = Font.system(size: 22, weight: .semibold, design: .default)
    static let ccHeadline = Font.system(size: 17, weight: .semibold, design: .default)
    static let ccBody = Font.system(size: 16, weight: .regular, design: .default)
    static let ccSubhead = Font.system(size: 15, weight: .regular, design: .default)
    static let ccFootnote = Font.system(size: 13, weight: .regular, design: .default)
    static let ccCaption = Font.system(size: 12, weight: .medium, design: .default)
    static let ccAmount = Font.system(size: 34, weight: .bold, design: .rounded)
    static let ccAmountLarge = Font.system(size: 52, weight: .bold, design: .rounded)
}

// MARK: - Primary Button

struct CCPrimaryButtonStyle: ButtonStyle {
    var color: Color = CCTheme.navy
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.ccHeadline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(color)
            .clipShape(Capsule())
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

struct CCSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.ccHeadline)
            .foregroundStyle(CCTheme.ink)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(CCTheme.fog)
            .clipShape(Capsule())
            .opacity(configuration.isPressed ? 0.85 : 1.0)
    }
}

// MARK: - Section

struct CCSection<Content: View>: View {
    let title: String
    var trailing: AnyView?
    @ViewBuilder let content: () -> Content

    init(_ title: String, trailing: AnyView? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.trailing = trailing
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: CCTheme.space3) {
            HStack {
                Text(title)
                    .font(.ccCaption)
                    .foregroundStyle(CCTheme.slate)
                    .textCase(.uppercase)
                    .tracking(0.5)
                Spacer()
                if let trailing {
                    trailing
                }
            }
            .padding(.horizontal, CCTheme.space5)

            content()
        }
    }
}

// MARK: - Avatar

struct CCAvatar: View {
    let user: User
    var size: CGFloat = 44

    var body: some View {
        Text(initials)
            .font(.system(size: size * 0.4, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(CCTheme.avatarColor(for: user.id))
            .clipShape(SwiftUI.Circle())
    }

    private var initials: String {
        let parts = user.name.split(separator: " ")
        let first = parts.first?.first.map(String.init) ?? ""
        let second = parts.dropFirst().first?.first.map(String.init) ?? ""
        return (first + second).uppercased()
    }
}

// MARK: - Color Hex

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Legacy aliases

extension CCTheme {
    static var primaryBlue: Color { navy }
    static var accentBlue: Color { navy }
    static var lightBlue: Color { fog }
    static var successGreen: Color { positive }
    static var warningOrange: Color { caution }
    static var errorRed: Color { red }
    static var backgroundPrimary: Color { canvas }
    static var backgroundCard: Color { canvas }
    static var textPrimary: Color { ink }
    static var textSecondary: Color { slate }

    static var paddingSmall: CGFloat { space2 }
    static var paddingMedium: CGFloat { space4 }
    static var paddingLarge: CGFloat { space6 }
    static var cornerRadiusSmall: CGFloat { radiusSmall }
    static var cornerRadiusMedium: CGFloat { radiusMedium }
    static var cornerRadiusLarge: CGFloat { radiusLarge }
}
