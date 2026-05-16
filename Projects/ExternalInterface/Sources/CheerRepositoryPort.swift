import struct Domain.BragPostID
import struct Domain.Cheer
import struct Domain.UserID

public struct CheerRepositoryPort: Sendable {
    public var addUnique: @Sendable (BragPostID, UserID) async throws -> Bool
    public var fetchCheers: @Sendable (BragPostID) async throws -> [Cheer]

    public init(
        addUnique: @escaping @Sendable (BragPostID, UserID) async throws -> Bool,
        fetchCheers: @escaping @Sendable (BragPostID) async throws -> [Cheer]
    ) {
        self.addUnique = addUnique
        self.fetchCheers = fetchCheers
    }
}
