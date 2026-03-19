import ProjectDescription
import ProjectDescriptionHelpers
import DependencyPlugin

let project = Project.makeModule(
    name: "JacsimClient",
    swiftLanguageVersion: .v6,
    targets: [.unitTest, .staticFramework],
    internalDependencies: [
        .domain,
        .ports,
        .adapters,
        .workflows
    ],
    externalDependencies: [
        .SPM.ComposableArchitecture
    ],
    tags: ["module", "jacsim-client"]
)
