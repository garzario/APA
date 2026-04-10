import SwiftUI

/// Design system for Capital Circles, following Capital One's brand guidelines.
enum CCTheme {
    // MARK: - Colors

    static let primaryBlue = Color(hex: "004977")
    static let accentBlue = Color(hex: "0078D4")
    static let lightBlue = Color(hex: "E8F4FD")

    static let successGreen = Color(hex: "1E8C45")
    static let warningOrange = Color(hex: "D4820A")
    static let errorRed = Color(hex: "D22630")

    static let cardVenture = Color(hex: "1A1A2E")
    static let cardSavor = Color(hex: "2D5016")
    static let cardQuicksilver = Color(hex: "4A4A4A")

    static let backgroundPrimary = Color(hex: "F8F9FA")
    static let backgroundCard = Color.white
    static let textPrimary = Color(hex: "1A1A1A")
    static let textSecondary = Color(hex: "6B7280")

    // MARK: - Spacing

    static let paddingSmall: CGFloat = 8
    static let paddingMedium: CGFloat = 16
    static let paddingLarge: CGFloat = 24

    // MARK: - Corner Radius

    static let cornerRadiusSmall: CGFloat = 8
    static let cornerRadiusMedium: CGFloat = 12
    static let cornerRadiusLarge: CGFloat = 16
}

// MARK: - Color Hex Extension

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
