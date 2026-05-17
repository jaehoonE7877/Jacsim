import Foundation
import SwiftData

public enum JacsimMigrationPlan: SchemaMigrationPlan {
    public static var schemas: [any VersionedSchema.Type] {
        [
            JacsimSchemaV1.self,
            JacsimSchemaV2.self,
            JacsimSchemaV3.self,
            JacsimSchemaV4.self,
            JacsimSchemaV5.self,
            CurrentSwiftDataSchema.self
        ]
    }

    public static var stages: [MigrationStage] {
        [
            migrateV1ToV2,
            .lightweight(fromVersion: JacsimSchemaV2.self, toVersion: JacsimSchemaV3.self),
            .lightweight(fromVersion: JacsimSchemaV3.self, toVersion: JacsimSchemaV4.self),
            .lightweight(fromVersion: JacsimSchemaV4.self, toVersion: JacsimSchemaV5.self),
            .lightweight(fromVersion: JacsimSchemaV5.self, toVersion: CurrentSwiftDataSchema.self)
        ]
    }

    private static let migrateV1ToV2 = MigrationStage.custom(
        fromVersion: JacsimSchemaV1.self,
        toVersion: JacsimSchemaV2.self,
        willMigrate: nil,
        didMigrate: { context in
            let descriptor = FetchDescriptor<JacsimSchemaV2.UserJacsimModel>()
            let tasks = try context.fetch(descriptor)
            for task in tasks where task.visibilityRaw != "private" {
                task.visibilityRaw = "private"
            }
            if !tasks.isEmpty {
                print("JacsimMigrationPlan V1→V2: migrated \(tasks.count) task rows with private visibility")
            }
            try context.save()
        }
    )

}

public final class SwiftDataStack: @unchecked Sendable {
    public static let shared = SwiftDataStack()
    
    public let container: ModelContainer
    
    private init() {
        do {
            container = try Self.makeContainer(isStoredInMemoryOnly: Self.isRunningTests)
        } catch {
            fatalError("SwiftData container initialization failed: \(error)")
        }
    }

    public static func makeContainer(isStoredInMemoryOnly: Bool = false) throws -> ModelContainer {
        let schema = Schema(versionedSchema: CurrentSwiftDataSchema.self)
        if !isStoredInMemoryOnly {
            try WidgetDataMigrationUseCase.migrateStoreIfNeeded(schema: schema)
        }
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: isStoredInMemoryOnly,
            groupContainer: isStoredInMemoryOnly ? .automatic : .identifier("group.com.jaehoon.jaksim")
        )
        let container = try ModelContainer(
            for: schema,
            migrationPlan: JacsimMigrationPlan.self,
            configurations: [config]
        )
        if !isStoredInMemoryOnly {
            try WidgetDataMigrationUseCase.markCompletedIfNeeded(in: container)
        }
        return container
    }

    public func makeContext() -> ModelContext {
        ModelContext(container)
    }

    private static var isRunningTests: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }
}
