import Combine
import Foundation
import UserNotifications

enum ReminderDestination: Equatable {
    case newExperience
    case revisit
}

enum ReminderKind: String, Codable, CaseIterable, Identifiable {
    case experienceEntry
    case revisit

    var id: String { rawValue }

    var title: String {
        switch self {
        case .experienceEntry:
            return "New experience"
        case .revisit:
            return "Revisit"
        }
    }

    var addMenuTitle: String {
        switch self {
        case .experienceEntry:
            return "To enter new experiences"
        case .revisit:
            return "To revisit experiences"
        }
    }

    var message: String {
        switch self {
        case .experienceEntry:
            return "Take a moment to notice something good."
        case .revisit:
            return "Take a moment to revisit something good."
        }
    }

    var destination: ReminderDestination {
        switch self {
        case .experienceEntry:
            return .newExperience
        case .revisit:
            return .revisit
        }
    }
}

final class ReminderManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = ReminderManager()

    @Published var pendingDestination: ReminderDestination?

    private let center = UNUserNotificationCenter.current()

    private override init() {
        super.init()
    }

    func configure() {
        center.delegate = self
    }

    func requestPermission(completion: @escaping (Bool, String?) -> Void) {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if let error {
                    completion(false, error.localizedDescription)
                } else if !granted {
                    completion(
                        false,
                        "Notifications are off. You can enable them in System Settings."
                    )
                } else {
                    completion(true, nil)
                }
            }
        }
    }

    func scheduleReminder(
        id: UUID,
        kind: ReminderKind,
        hour: Int,
        minute: Int,
        completion: @escaping (Bool, String?) -> Void = { _, _ in }
    ) {
        let identifier = notificationID(for: id)
        center.removePendingNotificationRequests(withIdentifiers: [identifier])

        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let content = UNMutableNotificationContent()
        content.title = "Greattitude"
        content.body = kind.message
        content.sound = .default
        content.userInfo = [
            "destination": kind.destination == .newExperience ? "newExperience" : "revisit"
        ]

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        center.add(request) { error in
            DispatchQueue.main.async {
                if let error {
                    completion(false, error.localizedDescription)
                } else {
                    completion(true, nil)
                }
            }
        }
    }

    func enableReminder(
        id: UUID,
        kind: ReminderKind,
        hour: Int,
        minute: Int,
        completion: @escaping (Bool, String?) -> Void
    ) {
        requestPermission { [weak self] granted, message in
            guard let self else { return }
            guard granted else {
                completion(false, message)
                return
            }
            self.scheduleReminder(
                id: id,
                kind: kind,
                hour: hour,
                minute: minute,
                completion: completion
            )
        }
    }

    func cancelReminder(id: UUID) {
        center.removePendingNotificationRequests(withIdentifiers: [notificationID(for: id)])
    }

    func consumePendingDestination() -> ReminderDestination? {
        let destination = pendingDestination
        pendingDestination = nil
        return destination
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let value = response.notification.request.content.userInfo["destination"] as? String
        DispatchQueue.main.async {
            switch value {
            case "newExperience":
                self.pendingDestination = .newExperience
            case "revisit":
                self.pendingDestination = .revisit
            default:
                break
            }
            completionHandler()
        }
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    private func notificationID(for id: UUID) -> String {
        "greattitude.reminder.\(id.uuidString)"
    }
}
