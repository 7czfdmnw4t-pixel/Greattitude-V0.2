import SwiftUI

private struct SavedReminder: Identifiable, Codable, Equatable {
    var id: UUID
    var kind: ReminderKind
    var hour: Int
    var minute: Int
    var isEnabled: Bool

    var time: Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components) ?? Date()
    }
}

struct ReminderSettingsView: View {
    @State private var reminders: [SavedReminder] = []
    @State private var statusMessage: String?

    private let storageKey = "greattitude.customReminders.v2"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("These reminders are meant as a helpful reminder in a sea of device notifications and distractions, to stay on top of your attitude and self-esteem. Set as many or as few as you like.")
                    .font(.system(size: 14))
                    .foregroundStyle(GreattitudeTheme.inkMuted)
                    .lineSpacing(3)

                if reminders.isEmpty {
                    Text("No reminders yet.")
                        .foregroundStyle(GreattitudeTheme.inkMuted)
                }

                ForEach($reminders) { $reminder in
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(alignment: .center, spacing: 12) {
                            Text(reminder.kind.title)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(GreattitudeTheme.ink)

                            Spacer()

                            Text(reminder.isEnabled ? "On" : "Off")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(GreattitudeTheme.inkMuted)

                            Toggle(
                                "Reminder on",
                                isOn: Binding(
                                    get: { reminder.isEnabled },
                                    set: { setEnabled($0, for: reminder.id) }
                                )
                            )
                            .toggleStyle(.switch)
                            .labelsHidden()
                            .tint(GreattitudeTheme.primary)
                        }

                        DatePicker(
                            "Time",
                            selection: Binding(
                                get: { reminder.time },
                                set: { setTime($0, for: reminder.id) }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                        .tint(GreattitudeTheme.primary)
                        .foregroundStyle(GreattitudeTheme.ink)

                        Text(reminder.kind.message)
                            .font(.system(size: 13))
                            .foregroundStyle(GreattitudeTheme.inkMuted)

                        Button("Delete reminder") {
                            deleteReminder(reminder.id)
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color(red: 0.62, green: 0.22, blue: 0.18))
                    }
                    .padding(16)
                    .background(
                        GreattitudeTheme.card,
                        in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(GreattitudeTheme.divider, lineWidth: 1)
                    }
                }

                Menu {
                    Button(ReminderKind.experienceEntry.addMenuTitle) {
                        addReminder(.experienceEntry)
                    }
                    Button(ReminderKind.revisit.addMenuTitle) {
                        addReminder(.revisit)
                    }
                } label: {
                    Text("Add reminder")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(GreattitudeTheme.primary)
                }

                if let statusMessage {
                    Text(statusMessage)
                        .font(.footnote)
                        .foregroundStyle(GreattitudeTheme.inkMuted)
                }
            }
            .padding(24)
            .frame(maxWidth: 560, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .greattitudeScreen()
        .navigationTitle("Reminders")
        .onAppear(perform: loadReminders)
    }

    private func addReminder(_ kind: ReminderKind) {
        let reminder = SavedReminder(
            id: UUID(),
            kind: kind,
            hour: kind == .experienceEntry ? 21 : 20,
            minute: 0,
            isEnabled: false
        )
        reminders.append(reminder)
        persistReminders()
        statusMessage = "Reminder added. Switch it on to enable it."
    }

    private func setEnabled(_ enabled: Bool, for id: UUID) {
        guard let index = reminders.firstIndex(where: { $0.id == id }) else { return }

        if !enabled {
            reminders[index].isEnabled = false
            persistReminders()
            ReminderManager.shared.cancelReminder(id: id)
            statusMessage = "Reminder turned off."
            return
        }

        let reminder = reminders[index]
        ReminderManager.shared.enableReminder(
            id: reminder.id,
            kind: reminder.kind,
            hour: reminder.hour,
            minute: reminder.minute
        ) { success, message in
            if success {
                if let currentIndex = reminders.firstIndex(where: { $0.id == id }) {
                    reminders[currentIndex].isEnabled = true
                    persistReminders()
                }
                statusMessage = "\(reminder.kind.title) reminder is on."
            } else {
                statusMessage = message ?? "Couldn’t enable this reminder."
            }
        }
    }

    private func setTime(_ date: Date, for id: UUID) {
        guard let index = reminders.firstIndex(where: { $0.id == id }) else { return }
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        reminders[index].hour = components.hour ?? 21
        reminders[index].minute = components.minute ?? 0
        persistReminders()

        let reminder = reminders[index]
        guard reminder.isEnabled else { return }

        ReminderManager.shared.scheduleReminder(
            id: reminder.id,
            kind: reminder.kind,
            hour: reminder.hour,
            minute: reminder.minute
        ) { success, message in
            statusMessage = success
                ? "\(reminder.kind.title) reminder updated."
                : message ?? "Couldn’t update this reminder."
        }
    }

    private func deleteReminder(_ id: UUID) {
        ReminderManager.shared.cancelReminder(id: id)
        reminders.removeAll { $0.id == id }
        persistReminders()
        statusMessage = "Reminder deleted."
    }

    private func persistReminders() {
        do {
            let data = try JSONEncoder().encode(reminders)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            statusMessage = "Couldn’t save reminder settings."
        }
    }

    private func loadReminders() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            reminders = [
                SavedReminder(id: UUID(), kind: .experienceEntry, hour: 21, minute: 0, isEnabled: false),
                SavedReminder(id: UUID(), kind: .revisit, hour: 20, minute: 0, isEnabled: false)
            ]
            persistReminders()
            return
        }

        do {
            reminders = try JSONDecoder().decode([SavedReminder].self, from: data)
        } catch {
            reminders = []
            statusMessage = "Couldn’t load saved reminders."
        }
    }
}
