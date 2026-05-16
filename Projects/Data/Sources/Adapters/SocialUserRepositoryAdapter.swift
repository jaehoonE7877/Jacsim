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

    public func searchUsers(query: String) async throws -> [Domain.User] {
        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalizedQuery.isEmpty else { return [] }

        let context = ModelContext(container)
        let users = try context.fetch(FetchDescriptor<UserModel>())
        return users
            .filter {
                $0.handle.lowercased().contains(normalizedQuery) ||
                    $0.displayName.lowercased().contains(normalizedQuery)
            }
            .map(mapToDomainModel(_:))
            .sorted { $0.displayName < $1.displayName }
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
