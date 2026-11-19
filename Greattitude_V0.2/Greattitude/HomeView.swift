import SwiftUI

enum AppRoute: Hashable {
    case revisit
    case experience(id: UUID, session: UUID)
    case complete(UUID)
    case reminders
}

final class AppRouter: ObservableObject {
    @Published var path: [AppRoute] = []

    func open(_ route: AppRoute) {
        path.append(route)
    }

    func replace(_ routes: [AppRoute]) {
        path = routes
    }
}

struct HomeView: View {
    @EnvironmentObject private var store: ExperienceStore
    @EnvironmentObject private var reminders: ReminderManager
    @StateObject private var router = AppRouter()
    @State private var showingNewExperience = false
    @State private var showingAbout = false
    @State private var showingPrivacy = false

    var body: some View {
        NavigationStack(path: $router.path) {
            VStack(spacing: 0) {
                Spacer(minLength: 24)

                VStack(spacing: 14) {
                    Image("GreattitudeLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .accessibilityHidden(true)

                    HStack(spacing: 8) {
                        Text("Greattitude")
                            .font(GreattitudeTheme.screenTitle)
                            .foregroundStyle(GreattitudeTheme.ink)

                        Button {
                            showingAbout = true
                        } label: {
                            Image(systemName: "info.circle")
                                .font(.system(size: 18, weight: .regular))
                                .foregroundStyle(GreattitudeTheme.inkMuted)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("About Greattitude")
                    }

                    Text("Notice what’s good.\nRemember how it felt.")
                        .font(.system(size: 17))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(GreattitudeTheme.inkMuted)
                        .lineSpacing(4)
                }

                Spacer(minLength: 36)

                VStack(spacing: 12) {
                    Button("Enter a new experience") {
                        showingNewExperience = true
                    }
                    .buttonStyle(PrimaryActionStyle())

                    Button("Revisit your experiences") {
                        router.open(.revisit)
                    }
                    .buttonStyle(SecondaryActionStyle())
                }

                Text("Greattitude keeps up to 10 experiences. When you add a new one, the oldest is replaced — so revisiting often matters.")
                    .font(.system(size: 13))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(GreattitudeTheme.inkMuted)
                    .lineSpacing(3)
                    .padding(.top, 16)

                Spacer(minLength: 40)

                VStack(spacing: 10) {
                    Button("Reminder settings") {
                        router.open(.reminders)
                    }
                    .buttonStyle(QuietTextStyle())

                    Button("Privacy") {
                        showingPrivacy = true
                    }
                    .buttonStyle(QuietTextStyle())
                }
                .padding(.bottom, 28)
            }
            .padding(.horizontal, 28)
            .frame(maxWidth: 520)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .greattitudeScreen()
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .revisit:
                    RevisitListView()
                case .experience(let id, let session):
                    ExperienceActionsView(experienceID: id)
                        .id(session)
                case .complete(let id):
                    ReflectionCompleteView(experienceID: id)
                case .reminders:
                    ReminderSettingsView()
                }
            }
            .sheet(isPresented: $showingNewExperience) {
                NewExperienceView()
                    .environmentObject(store)
            }
            .sheet(isPresented: $showingAbout) {
                AboutSheet()
            }
            .sheet(isPresented: $showingPrivacy) {
                PrivacySheet()
            }
            .onChange(of: reminders.pendingDestination) { _, destination in
                guard let destination else { return }
                _ = reminders.consumePendingDestination()
                switch destination {
                case .newExperience:
                    showingNewExperience = true
                case .revisit:
                    router.replace([.revisit])
                }
            }
        }
        .environmentObject(router)
    }
}

struct AboutSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Processing positive experiences — really noticing them, writing them down, and remembering how they felt — helps rewire how you see yourself and builds self-esteem from real moments, not empty affirmations.")
                        .font(.system(size: 16))
                        .foregroundStyle(GreattitudeTheme.ink)
                        .lineSpacing(4)

                    Text("Greattitude guides you through capturing what happened, why it mattered, what you’d say to someone else, and what it shows about you. Then you revisit those moments so the feeling sticks.")
                        .font(.system(size: 16))
                        .foregroundStyle(GreattitudeTheme.ink)
                        .lineSpacing(4)

                    Text("The app keeps up to 10 experiences. When you add a new one, the oldest is replaced with the newest — so revisiting often matters before an experience drops off the list.")
                        .font(.system(size: 15))
                        .foregroundStyle(GreattitudeTheme.inkMuted)
                        .lineSpacing(4)
                }
                .padding(24)
                .frame(maxWidth: 560, alignment: .leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .greattitudeScreen()
            .navigationTitle("About")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 420, minHeight: 360)
        #endif
    }
}

struct PrivacySheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Your experiences and reminder settings are stored only locally on this device, inside the Greattitude app. They are not shared or sent anywhere else.")
                        .font(.system(size: 16))
                        .foregroundStyle(GreattitudeTheme.ink)
                        .lineSpacing(4)
                }
                .padding(24)
                .frame(maxWidth: 560, alignment: .leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .greattitudeScreen()
            .navigationTitle("Privacy")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 420, minHeight: 280)
        #endif
    }
}
