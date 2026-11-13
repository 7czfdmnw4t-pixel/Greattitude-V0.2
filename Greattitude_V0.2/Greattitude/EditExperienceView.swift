import SwiftUI

struct EditExperienceView: View {
    let experience: Experience
    var onDeleted: () -> Void = {}

    @EnvironmentObject private var store: ExperienceStore
    @Environment(\.dismiss) private var dismiss

    @State private var answer1: String
    @State private var answer2: String
    @State private var answer3: String
    @State private var answer4: String
    @State private var errorMessage: String?
    @State private var showingDelete = false

    init(experience: Experience, onDeleted: @escaping () -> Void = {}) {
        self.experience = experience
        self.onDeleted = onDeleted
        _answer1 = State(initialValue: experience.answers.answer1)
        _answer2 = State(initialValue: experience.answers.answer2)
        _answer3 = State(initialValue: experience.answers.answer3)
        _answer4 = State(initialValue: experience.answers.answer4)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        editor("The Experience", text: $answer1)
                        editor("Why it was good", text: $answer2)
                        editor("What you’d tell someone else", text: $answer3)
                        editor("What you learned", text: $answer4)

                        if let errorMessage {
                            Text(errorMessage)
                                .foregroundStyle(.red)
                        }
                    }
                    .padding(24)
                }

                Button("Delete experience") {
                    showingDelete = true
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color(red: 0.62, green: 0.22, blue: 0.18))
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .greattitudeScreen()
            .navigationTitle("Edit experience")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                }
            }
            .alert("Delete this experience?", isPresented: $showingDelete) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    deleteExperience()
                }
            } message: {
                Text("This permanently deletes the experience. This can’t be undone.")
            }
        }
        #if os(macOS)
        .frame(minWidth: 480, minHeight: 560)
        #endif
    }

    private func editor(_ title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .tracking(0.6)
                .textCase(.uppercase)
                .foregroundStyle(GreattitudeTheme.inkMuted)

            TextEditor(text: text)
                .font(.system(size: 17))
                .scrollContentBackground(.hidden)
                .padding(10)
                .frame(minHeight: 110)
                .background(
                    GreattitudeTheme.card,
                    in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(GreattitudeTheme.divider, lineWidth: 1)
                }
                .foregroundStyle(GreattitudeTheme.ink)
        }
    }

    private func save() {
        do {
            let answers = try ReflectionAnswers(
                answer1: answer1,
                answer2: answer2,
                answer3: answer3,
                answer4: answer4
            )
            try store.edit(id: experience.id, answers: answers)
            dismiss()
        } catch ReflectionValidationError.allFourAnswersRequired {
            errorMessage = "Please fill in all four answers before saving."
        } catch {
            errorMessage = "Your changes could not be saved. Please try again."
        }
    }

    private func deleteExperience() {
        do {
            try store.delete(id: experience.id)
            dismiss()
            onDeleted()
        } catch {
            errorMessage = "The experience could not be deleted. Please try again."
        }
    }
}
