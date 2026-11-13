import SwiftUI

struct ExperienceActionsView: View {
    let experienceID: UUID

    @EnvironmentObject private var store: ExperienceStore
    @EnvironmentObject private var router: AppRouter

    @State private var revealedCount = 1
    @State private var showingEdit = false
    @State private var errorMessage: String?

    private var experience: Experience? {
        store.experience(id: experienceID)
    }

    private var primaryTitle: String {
        switch revealedCount {
        case 1: return "Reflect on this"
        case 4: return "Finish"
        default: return "Continue"
        }
    }

    var body: some View {
        Group {
            if let experience {
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 22) {
                            Text(experience.createdAt.formatted(date: .complete, time: .omitted))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(GreattitudeTheme.inkMuted)

                            ForEach(Array(ReflectionPrompt.allCases.prefix(revealedCount))) { prompt in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(prompt.revisitHeading)
                                        .font(.system(size: 13, weight: .semibold))
                                        .tracking(0.6)
                                        .textCase(.uppercase)
                                        .foregroundStyle(GreattitudeTheme.inkMuted)

                                    Text(prompt.answer(in: experience.answers))
                                        .font(.system(size: 22, weight: .regular))
                                        .foregroundStyle(GreattitudeTheme.ink)
                                }
                            }

                            if let errorMessage {
                                Text(errorMessage)
                                    .foregroundStyle(Color.red)
                            }
                        }
                        .padding(24)
                        .frame(maxWidth: 560, alignment: .leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    VStack(spacing: 12) {
                        Button(primaryTitle) {
                            advance(experience)
                        }
                        .buttonStyle(PrimaryActionStyle())

                        Button("Edit experience") {
                            showingEdit = true
                        }
                        .buttonStyle(SecondaryActionStyle())
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                    .padding(.top, 8)
                    .frame(maxWidth: 560)
                    .frame(maxWidth: .infinity)
                }
            } else {
                Text("This experience is no longer available.")
                    .foregroundStyle(GreattitudeTheme.ink)
                    .padding(24)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .greattitudeScreen()
        .navigationTitle("Experience")
        .sheet(isPresented: $showingEdit) {
            if let experience {
                EditExperienceView(experience: experience) {
                    router.replace([.revisit])
                }
                .environmentObject(store)
            }
        }
    }

    private func advance(_ experience: Experience) {
        if revealedCount < 4 {
            revealedCount += 1
            errorMessage = nil
            return
        }

        do {
            try store.completeRevisit(id: experience.id)
            router.open(.complete(experience.id))
        } catch {
            errorMessage = "This revisit could not be saved. Please try again."
        }
    }
}
