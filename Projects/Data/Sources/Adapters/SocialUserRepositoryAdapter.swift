import Domain
import Foundation
import SwiftData

public actor SocialUserRepositoryAdapter {
    private let container: ModelContainer

    public init(container: ModelContainer = SwiftDataStack.shared.container) {
        self.container = container
    }

    public func fetchUser(id: UserID) async throws -> Domain.User? {
        let context = ModelContext(container)
        let users = try context.fetch(FetchDescriptor<UserModel>())
        return users.first { $0.id == id.rawValue }.map(mapToDomainModel(_:))
    }

    public func fetchUserByHandle(_ handle: String) async throws -> Domain.User? {
        let context = ModelContext(container)
        let users = try context.fetch(FetchDescriptor<UserModel>())
        return users.first { $0.handle == handle }.map(mapToDomainModel(_:))
    }

    public func upsertUser(_ user: Domain.User) async throws {
        let context = ModelContext(container)
        let users = try context.fetch(FetchDescriptor<UserModel>())
        let existing = users.first { $0.id == user.id.rawValue }
        let model = mapToSwiftDataModel(user, existing: existing)
        if existing == nil {
            context.insert(model)
        }
        try context.save()
    }
}
