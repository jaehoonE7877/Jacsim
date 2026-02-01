import Foundation
import SwiftData

@MainActor
public final class SwiftDataStack: @unchecked Sendable {
    public static let shared = SwiftDataStack()
    
    public let container: ModelContainer
    public let context: ModelContext
    
    private init() {
        let schema = Schema([UserJacsimModel.self, CertifiedModel.self, StageModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            container = try ModelContainer(for: schema, configurations: [config])
            context = container.mainContext
        } catch {
            fatalError("SwiftData container initialization failed: \(error)")
        }
    }
}
