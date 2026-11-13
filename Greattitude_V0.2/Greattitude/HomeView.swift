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

                    Text("Greattitude")
                        .font(GreattitudeTheme.screenTitle)
                        .foregroundStyle(GreattitudeTheme.ink)

                    Text("Notice what’s good.\nRemember how it felt.")
                        .font(.system(size: 17))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(GreattitudeTheme.inkMuted)
                        .lineSpacing(4)
                }

                Spacer(minLength: 36)

                VStack(spacing: 12) {
                    Button("Revisit your experiences") {
                        router.open(.revisit)
                    }
                    .buttonStyle(PrimaryActionStyle())

                    Button("Enter a new experience") {
                        showingNewExperience = true
                    }
                    .buttonStyle(SecondaryActionStyle())
                }

                Spacer(minLength: 40)

                Button("Reminder settings") {
                    router.open(.reminders)
                }
                .buttonStyle(QuietTextStyle())
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
