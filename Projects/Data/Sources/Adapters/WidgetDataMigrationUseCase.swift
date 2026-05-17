import Foundation
import SwiftData

public enum WidgetDataMigrationUseCase {
    private static let appGroupIdentifier = "group.com.jaehoon.jaksim"

    public static func migrateStoreIfNeeded(schema: Schema) throws {
        let fileManager = FileManager.default
        let legacyConfig = ModelConfiguration(schema: schema, groupContainer: .automatic)
        let sharedConfig = ModelConfiguration(schema: schema, groupContainer: .identifier(appGroupIdentifier))
        let legacyStoreURL = legacyConfig.url
        let sharedStoreURL = sharedConfig.url

        guard fileManager.fileExists(atPath: legacyStoreURL.path) else { return }
        guard !fileManager.fileExists(atPath: sharedStoreURL.path) else { return }

        try fileManager.createDirectory(
            at: sharedStoreURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        for sourceURL in storeFileURLs(for: legacyStoreURL, fileManager: fileManager) {
            let destinationURL = sharedStoreURL
                .deletingLastPathComponent()
                .appendingPathComponent(sourceURL.lastPathComponent)
            if fileManager.fileExists(atPath: destinationURL.path) {
                continue
            }
            try fileManager.copyItem(at: sourceURL, to: destinationURL)
        }
    }

    public static func markCompletedIfNeeded(in container: ModelContainer) throws {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<AppSettingsModel>()
        let settings = try context.fetch(descriptor).first ?? AppSettingsModel(id: "global")
        if settings.modelContext == nil {
            context.insert(settings)
        }
        guard settings.widgetMigrationV1Done != true else { return }
        settings.widgetMigrationV1Done = true
        try context.save()
    }

    private static func storeFileURLs(for storeURL: URL, fileManager: FileManager) -> [URL] {
        let directory = storeURL.deletingLastPathComponent()
        let storeName = storeURL.lastPathComponent
        guard let contents = try? fileManager.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: nil
        ) else {
            return [storeURL]
        }
        return contents.filter { $0.lastPathComponent.hasPrefix(storeName) }
    }
}
