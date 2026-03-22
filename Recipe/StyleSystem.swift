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
}

enum AppFonts {
    static let czizh = "DelphianC"
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

// MARK: - Общие стили

struct PrimaryTitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        let gradient = LinearGradient(
            colors: [AppColors.accentPurple, AppColors.accentPink],
            startPoint: .leading,
            endPoint: .trailing
        )

        return content
            .font(.custom(AppFonts.subtitle, size: 32, relativeTo: .title))
            .foregroundColor(.clear)
            .overlay(
                gradient.mask(
                    content
                        .font(.custom(AppFonts.subtitle, size: 32, relativeTo: .title))
                )
            )
            .multilineTextAlignment(.center)
    }
}

struct SecondaryTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom(AppFonts.subtitle, size: 16, relativeTo: .body))
            .foregroundColor(AppColors.textSecondary)
            .multilineTextAlignment(.center)
    }
}

extension View {
    func primaryTitle() -> some View {
        modifier(PrimaryTitleStyle())
    }

    func secondaryText() -> some View {
        modifier(SecondaryTextStyle())
    }

    func recipeNameTitle() -> some View {
        modifier(RecipeNameTitleStyle())
    }
}

struct RecipeNameTitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        let gradient = LinearGradient(
            colors: [AppColors.accentPurple, AppColors.accentPink],
            startPoint: .leading,
            endPoint: .trailing
        )

        return content
            .font(.system(size: 22, weight: .semibold, design: .rounded))
            .foregroundColor(.clear)
            .overlay(
                gradient.mask(
                    content
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                )
            )
            .multilineTextAlignment(.center)
    }
}

// MARK: - Анимации появления

struct ScreenAppearModifier: ViewModifier {
    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .animation(.easeOut(duration: 0.35), value: isVisible)
            .onAppear {
                isVisible = true
            }
    }
}

struct TextAppearModifier: ViewModifier {
    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .scaleEffect(isVisible ? 1 : 0.98)
            .animation(.easeOut(duration: 0.25), value: isVisible)
            .onAppear {
                isVisible = true
            }
    }
}

extension View {
    func screenAppear() -> some View {
        modifier(ScreenAppearModifier())
    }

    func animatedText() -> some View {
        modifier(TextAppearModifier())
    }
}

// MARK: - Общие компоненты

struct PillButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        let gradient = LinearGradient(
            colors: [
                AppColors.accentPurple,
                AppColors.accentPink
            ],
            startPoint: .leading,
            endPoint: .trailing
        )

        return configuration.label
            .font(.custom(AppFonts.title, size: 18, relativeTo: .body))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                gradient.opacity(0.6)
            )
            .cornerRadius(26)
            .shadow(color: AppColors.textPrimary.opacity(configuration.isPressed ? 0.08 : 0.4),
                    radius: configuration.isPressed ? 4 : 4,
                    x: 4,
                    y: configuration.isPressed ? 2 : 3)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

struct GradientInputFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        let gradient = LinearGradient(
            colors: [
                AppColors.accentPurple,
                AppColors.accentPink
            ],
            startPoint: .leading,
            endPoint: .trailing
        )

        return content
            .background(Color.white.opacity(0.9))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(gradient.opacity(0.3), lineWidth: 1.4)
            )
            .cornerRadius(18)
    }
}

extension View {
    func gradientInputField() -> some View {
        modifier(GradientInputFieldStyle())
    }
}

struct CardContainer<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(AppColors.cardBackground)
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(AppColors.cardStroke, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 4, y: 2)
            .contentShape(Rectangle())
    }
}

