import Foundation
import SwiftData
import Domain
import ExternalInterface

public actor UserSettingsRepositoryAdapter {
    private let container: ModelContainer
    
    public init(container: ModelContainer = SwiftDataStack.shared.container) {
        self.container = container
    }
    
    public func isNotificationEnabled() async -> Bool {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<UserJacsimModel>()
        let results = (try? context.fetch(descriptor)) ?? []
        return results.contains { $0.isNotificationEnabled }
    }
    
    public func getAllReminders() async -> [ReminderInfo] {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<UserJacsimModel>()
        let results = (try? context.fetch(descriptor)) ?? []
        
        return results.compactMap { model in
            guard model.isNotificationEnabled else { return nil }
            guard let alarm = model.alarm else { return nil }
            let time = Calendar.current.dateComponents([.hour, .minute], from: alarm)
            return ReminderInfo(taskId: TaskID(model.id), title: model.title, time: time)
        }
    }
    
    public func updateNotificationEnabled(_ enabled: Bool) async {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<UserJacsimModel>()
        guard let models = try? context.fetch(descriptor) else { return }
        
        for model in models {
            model.isNotificationEnabled = enabled
        }
        
        try? context.save()
    }
}
