import struct Domain.BragPostID
import struct Domain.Cheer
import struct Domain.UserID

public struct CheerRepositoryPort: Sendable {
    public var addUnique: @Sendable (BragPostID, UserID) async throws -> Void
    public var fetchCheers: @Sendable (BragPostID) async throws -> [Cheer]

    public init(
        addUnique: @escaping @Sendable (BragPostID, UserID) async throws -> Void,
        fetchCheers: @escaping @Sendable (BragPostID) async throws -> [Cheer]
    ) {
        self.addUnique = addUnique
        self.fetchCheers = fetchCheers
    }
}
