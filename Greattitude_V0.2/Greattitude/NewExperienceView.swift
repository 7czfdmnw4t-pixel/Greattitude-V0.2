import SwiftUI

struct NewExperienceView: View {
    @EnvironmentObject private var store: ExperienceStore
    @Environment(\.dismiss) private var dismiss

    @State private var step = 1
    @State private var answer1 = ""
    @State private var answer2 = ""
    @State private var answer3 = ""
    @State private var answer4 = ""
    @State private var saveError: String?

    private var prompt: ReflectionPrompt {
        ReflectionPrompt(rawValue: step) ?? .experience
    }

    private var currentAnswer: String {
        switch step {
        case 1: return answer1
        case 2: return answer2
        case 3: return answer3
        default: return answer4
        }
    }

    private var currentAnswerIsComplete: Bool {
        !currentAnswer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Step \(step)")
                            .font(.subheadline)
                            .foregroundStyle(GreattitudeTheme.inkMuted)

                        ProgressView(value: Double(step), total: 4)
                            .tint(GreattitudeTheme.primary)

                        Text(prompt.entryQuestion)
                            .font(GreattitudeTheme.heading)
                            .foregroundStyle(GreattitudeTheme.ink)

                        Text(prompt.entryGuidance)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(GreattitudeTheme.inkMuted)
                            .lineSpacing(3)

                        Text(prompt.entryExamples)
                            .font(.system(size: 14).italic())
                            .foregroundStyle(GreattitudeTheme.inkMuted)
                            .lineSpacing(3)

                        editor

                        if let saveError {
                            Text(saveError)
                                .foregroundStyle(.red)
                                .font(.subheadline)
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: 560, alignment: .leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                HStack(spacing: 12) {
                    if step > 1 {
                        Button("Back") {
                            step -= 1
                            saveError = nil
                        }
                        .buttonStyle(SecondaryActionStyle())
                    }

                    Button(step == 4 ? "Save experience" : "Continue") {
                        continueOrSave()
                    }
                    .buttonStyle(PrimaryActionStyle(enabled: currentAnswerIsComplete))
                    .disabled(!currentAnswerIsComplete)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                .padding(.top, 8)
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
            }
            .greattitudeScreen()
            .navigationTitle("New experience")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var editor: some View {
        switch step {
        case 1:
            answerEditor($answer1)
        case 2:
            answerEditor($answer2)
        case 3:
            answerEditor($answer3)
        default:
            answerEditor($answer4)
        }
    }

    private func answerEditor(_ text: Binding<String>) -> some View {
        TextEditor(text: text)
            .font(.system(size: 17))
            .scrollContentBackground(.hidden)
            .padding(10)
            .frame(minHeight: 160)
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

    private func continueOrSave() {
        guard currentAnswerIsComplete else { return }
        if step < 4 {
            step += 1
            saveError = nil
        } else {
            save()
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
            try store.add(answers: answers)
            dismiss()
        } catch {
            saveError = "Your experience could not be saved. Please try again."
        }
    }
}
