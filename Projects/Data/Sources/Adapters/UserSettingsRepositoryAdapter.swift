import Foundation
import SwiftData
import Domain
import ExternalInterface

public actor UserSettingsRepositoryAdapter {
    private enum GlobalSettings {
        static let id = "global"
    }

    private let context: ModelContext
    
    public init(context: ModelContext = SwiftDataStack.shared.makeContext()) {
        self.context = context
    }
    
    public func isNotificationEnabled() async -> Bool {
        fetchOrCreateGlobalSettings().isNotificationEnabled
    }
    
    public func getAllReminders() async -> [ReminderInfo] {
        let descriptor = FetchDescriptor<UserJacsimModel>(
            predicate: #Predicate { $0.isNotificationEnabled == true && $0.alarm != nil }
        )
        let results = (try? context.fetch(descriptor)) ?? []
        
        return results.compactMap { model in
            guard let alarm = model.alarm else { return nil }
            let time = Calendar.current.dateComponents([.hour, .minute], from: alarm)
            return ReminderInfo(taskId: TaskID(model.id), title: model.title, time: time)
        }
    }
    
    public func updateNotificationEnabled(_ enabled: Bool) async {
        let settings = fetchOrCreateGlobalSettings()
        settings.isNotificationEnabled = enabled
        try? context.save()
    }

    private func fetchOrCreateGlobalSettings() -> AppSettingsModel {
        let settingsDescriptor = FetchDescriptor<AppSettingsModel>()
        if let existing = (try? context.fetch(settingsDescriptor))?.first(where: { $0.id == GlobalSettings.id }) {
            return existing
        }

        // Migrate previous behavior where global toggle was inferred from task rows.
        let taskDescriptor = FetchDescriptor<UserJacsimModel>()
        let inferredGlobalToggle = ((try? context.fetch(taskDescriptor)) ?? []).contains { $0.isNotificationEnabled }

        let settings = AppSettingsModel(id: GlobalSettings.id, isNotificationEnabled: inferredGlobalToggle)
        context.insert(settings)
        try? context.save()
        return settings
    }
}
