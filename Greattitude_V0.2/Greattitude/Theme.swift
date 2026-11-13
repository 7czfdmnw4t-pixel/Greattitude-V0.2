import SwiftUI

enum GreattitudeTheme {
    /// Warm paper background.
    static let cream = Color(red: 0.96, green: 0.94, blue: 0.89)

    /// Card surface, slightly lighter than cream.
    static let card = Color(red: 0.99, green: 0.98, blue: 0.95)

    /// Near-charcoal for titles — high contrast on cream.
    static let ink = Color(red: 0.14, green: 0.16, blue: 0.14)

    static let inkMuted = Color(red: 0.32, green: 0.34, blue: 0.31)

    /// Sage used as a fill, not as small text on cream.
    static let primary = Color(red: 0.22, green: 0.38, blue: 0.28)

    static let mist = Color(red: 0.86, green: 0.90, blue: 0.94)

    static let divider = Color(red: 0.78, green: 0.80, blue: 0.74)

    static let screenTitle = Font.system(.largeTitle, design: .serif).weight(.semibold)

    static let heading = Font.system(.title3, design: .serif).weight(.semibold)

    static let body = Font.system(.body, design: .default)
}

struct GreattitudeScreen: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(GreattitudeTheme.cream.ignoresSafeArea())
            .preferredColorScheme(.light)
            .tint(GreattitudeTheme.primary)
            #if os(iOS)
            .toolbarBackground(GreattitudeTheme.cream, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            #else
            .toolbarBackground(GreattitudeTheme.cream, for: .windowToolbar)
            .toolbarBackground(.visible, for: .windowToolbar)
            .toolbarColorScheme(.light, for: .windowToolbar)
            #endif
    }
}

extension View {
    func greattitudeScreen() -> some View {
        modifier(GreattitudeScreen())
    }
}

struct PrimaryActionStyle: ButtonStyle {
    var enabled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                GreattitudeTheme.primary.opacity(enabled ? (configuration.isPressed ? 0.82 : 1) : 0.4),
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
    }
}

struct SecondaryActionStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(GreattitudeTheme.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                GreattitudeTheme.card.opacity(configuration.isPressed ? 0.7 : 1),
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(GreattitudeTheme.primary.opacity(0.55), lineWidth: 1.5)
            }
    }
}

struct QuietTextStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .regular))
            .foregroundStyle(GreattitudeTheme.inkMuted.opacity(configuration.isPressed ? 0.6 : 1))
            .underline()
    }
}
