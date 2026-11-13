import SwiftUI

@main
struct GreattitudeApp: App {
    @StateObject private var experienceStore: ExperienceStore
    @State private var startupError: String?

    init() {
        ReminderManager.shared.configure()

        let store: ExperienceStore
        var errorMessage: String?
        do {
            store = try ExperienceStore()
        } catch {
            store = ExperienceStore.placeholder
            errorMessage = error.localizedDescription
        }
        _experienceStore = StateObject(wrappedValue: store)
        _startupError = State(initialValue: errorMessage)
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if let startupError {
                    StartupErrorView(message: startupError)
                } else {
                    HomeView()
                        .environmentObject(experienceStore)
                        .environmentObject(ReminderManager.shared)
                }
            }
            .tint(GreattitudeTheme.primary)
            .preferredColorScheme(.light)
        }
        #if os(macOS)
        .defaultSize(width: 720, height: 820)
        #endif
    }
}

private struct StartupErrorView: View {
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            Text("Greattitude couldn’t start")
                .font(GreattitudeTheme.screenTitle)
                .foregroundStyle(GreattitudeTheme.ink)

            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(GreattitudeTheme.inkMuted)
        }
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(GreattitudeTheme.cream.ignoresSafeArea())
    }
}
