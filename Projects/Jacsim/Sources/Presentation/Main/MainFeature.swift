import Observation

@MainActor
@Observable
public final class MainModel {
    public let home: HomeModel

    public init(dependencies: JacsimDependencies) {
        self.home = HomeModel(dependencies: dependencies)
    }
}
