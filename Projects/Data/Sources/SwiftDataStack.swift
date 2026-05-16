import Foundation
import SwiftData

public enum JacsimMigrationPlan: SchemaMigrationPlan {
    public static var schemas: [any VersionedSchema.Type] {
        [
            JacsimSchemaV1.self,
            JacsimSchemaV2.self
        ]
    }

    public static var stages: [MigrationStage] {
        [
            migrateV1ToV2
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
        let schema = Schema(versionedSchema: JacsimSchemaV2.self)
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: isStoredInMemoryOnly)
        return try ModelContainer(
            for: schema,
            migrationPlan: JacsimMigrationPlan.self,
            configurations: [config]
        )
    }

    public func makeContext() -> ModelContext {
        ModelContext(container)
    }

    private static var isRunningTests: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }
}
