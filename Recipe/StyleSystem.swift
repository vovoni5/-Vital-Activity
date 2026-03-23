import SwiftUI

// MARK: - Цвета и шрифты

struct AppColors {
    static let accentPink = Color(red: 0.95, green: 0.25, blue: 0.65)
    static let accentPurple = Color(red: 0.47, green: 0.20, blue: 0.95)
    static let softWhite = Color.white.opacity(0.95)
    static let textPrimary = Color(red: 0.16, green: 0.11, blue: 0.25)
    static let textSecondary = Color(red: 0.38, green: 0.32, blue: 0.52)
    static let cardBackground = Color.white.opacity(0.96)
    static let cardStroke = Color.white.opacity(0.6)
    static let textPole = Color(red: 0.80, green: 0.75, blue: 0.88)
    static let swipeActionText = Color(red: 0.80, green: 0.75, blue: 0.88) // по умолчанию textPole
}

enum AppFonts {
    static let apple = "Apple Chancery"
    static let title = "Montserrat Alternates"
    static let subtitle = "Optima"
    static let button = "Hero"
    static let chip = "Kreadon"
    static let numeric = "Geoform"
}


struct AppGradientBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    AppColors.softWhite,
                    Color(red: 0.99, green: 0.88, blue: 1.0),
                    Color(red: 0.96, green: 0.78, blue: 0.99)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                gradient: Gradient(colors: [
                    AppColors.accentPurple.opacity(0.55),
                    .clear
                ]),
                center: .topTrailing,
                startRadius: 40,
                endRadius: 420
            )

            RadialGradient(
                gradient: Gradient(colors: [
                    AppColors.accentPink.opacity(0.55),
                    .clear
                ]),
                center: .bottomLeading,
                startRadius: 60,
                endRadius: 420
            )
            Image("white-abstract-texture-background")
                            .resizable()
                            .scaledToFill() // Вместо .aspectRatio
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                            .clipped()
                            .opacity(0.1)
        }
        .background(Color.white)
    }
}


