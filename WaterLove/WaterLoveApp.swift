import SwiftUI
import UserNotifications

@main
struct WaterLoveApp: App {
    @Environment(\.scenePhase) private var scenePhase

    @State private var recordStore: WaterRecordStore
    @State private var settingsStore: UserSettingsStore

    private let notificationDelegate = NotificationDelegate()
    private let notificationService: NotificationService

    init() {
        let recordStore = WaterRecordStore()
        let settingsStore = UserSettingsStore()

        _recordStore = State(initialValue: recordStore)
        _settingsStore = State(initialValue: settingsStore)
        notificationService = NotificationService(
            recordStore: recordStore,
            settingsStore: settingsStore
        )

        UNUserNotificationCenter.current().delegate = notificationDelegate
    }

    var body: some Scene {
        WindowGroup {
            MainTabView(
                recordStore: recordStore,
                settingsStore: settingsStore,
                notificationService: notificationService
            )
            .task {
                await refreshNotificationSchedule()
            }
            .onChange(of: scenePhase) { _, newPhase in
                guard newPhase == .active else { return }
                Task {
                    await refreshNotificationSchedule()
                }
            }
        }
    }

    private func refreshNotificationSchedule() async {
        try? await notificationService.rescheduleNotificationsIfNeeded()
    }
}
