import ProjectDescription
import ProjectDescriptionHelpers
import DependencyPlugin

let project = Project.makeFrameworkProject(
    name: "JacsimClient",
    swiftLanguageVersion: .v6,
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
