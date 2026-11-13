import SwiftUI

struct ReflectionCompleteView: View {
    let experienceID: UUID

    @EnvironmentObject private var store: ExperienceStore
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        VStack(spacing: 28) {
            Spacer(minLength: 20)

            VStack(spacing: 14) {
                Text("That’s it.")
                    .font(GreattitudeTheme.screenTitle)
                    .foregroundStyle(GreattitudeTheme.ink)

                Text("You’ve revisited the experience and helped to build self-esteem and look for the positives.")
                    .font(.system(size: 18))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(GreattitudeTheme.inkMuted)
                    .lineSpacing(4)
            }

            Spacer(minLength: 20)

            VStack(spacing: 12) {
                Button("Next experience") {
                    goToNext()
                }
                .buttonStyle(PrimaryActionStyle())

                Button("Home") {
                    router.replace([])
                }
                .buttonStyle(SecondaryActionStyle())
            }
        }
        .padding(28)
        .frame(maxWidth: 520)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .greattitudeScreen()
        .navigationTitle("Done")
        .navigationBarBackButtonHidden(true)
    }

    private func goToNext() {
        if let next = store.experienceAfter(experienceID) {
            router.replace([
                .revisit,
                .experience(id: next.id, session: UUID())
            ])
        } else {
            router.replace([.revisit])
        }
    }
}
