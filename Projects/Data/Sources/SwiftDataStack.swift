import Foundation
import SwiftData

public final class SwiftDataStack: @unchecked Sendable {
    public static let shared = SwiftDataStack()
    
    public let container: ModelContainer
    
    private init() {
        let schema = Schema([
            UserJacsimModel.self,
            AppSettingsModel.self,
            CertifiedModel.self,
            StageModel.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("SwiftData container initialization failed: \(error)")
        }
    }

    public func makeContext() -> ModelContext {
        ModelContext(container)
    }
}
