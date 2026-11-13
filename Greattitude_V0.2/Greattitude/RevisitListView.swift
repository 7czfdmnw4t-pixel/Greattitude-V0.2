import SwiftUI

struct RevisitListView: View {
    @EnvironmentObject private var store: ExperienceStore
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        Group {
            if store.oldestFirst.isEmpty {
                VStack(spacing: 16) {
                    Text("Nothing to revisit yet")
                        .font(GreattitudeTheme.heading)
                        .foregroundStyle(GreattitudeTheme.ink)

                    Text("Enter an experience first. It will show up here, oldest at the top.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(GreattitudeTheme.inkMuted)

                    Text("Tap on an experience to start your reflection")
                        .font(.system(size: 17))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(GreattitudeTheme.inkMuted)
                        .lineSpacing(4)
                }
                .padding(28)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Tap on an experience to start your reflection")
                            .font(.system(size: 17))
                            .foregroundStyle(GreattitudeTheme.inkMuted)
                            .lineSpacing(4)

                        Text("Intentionally revisiting positive experiences AND remembering HOW IT FELT will positively alter your perception of situations, events and yourself. Just remember to FEEL what it was like, even if only for a few seconds.")
                            .font(.system(size: 14))
                            .foregroundStyle(GreattitudeTheme.inkMuted)
                            .lineSpacing(3)

                        LazyVStack(spacing: 10) {
                            ForEach(store.oldestFirst) { experience in
                                Button {
                                    router.open(.experience(id: experience.id, session: UUID()))
                                } label: {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(experience.createdAt.formatted(date: .abbreviated, time: .omitted))
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundStyle(GreattitudeTheme.inkMuted)

                                        Text(experience.answers.answer1)
                                            .font(.system(size: 17, weight: .regular))
                                            .foregroundStyle(GreattitudeTheme.ink)
                                            .multilineTextAlignment(.leading)
                                            .lineLimit(3)
                                    }
                                    .padding(18)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(
                                        GreattitudeTheme.card,
                                        in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    )
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .stroke(GreattitudeTheme.divider, lineWidth: 1)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
        }
        .greattitudeScreen()
        .navigationTitle("Revisit")
    }
}
