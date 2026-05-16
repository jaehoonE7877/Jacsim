import ProjectDescription
import ProjectDescriptionHelpers
import DependencyPlugin

let project = Project.makeModule(
    name: "Data",
    swiftLanguageVersion: .v6,
    targets: [.unitTest, .staticFramework],
    internalDependencies: [
        .domain,
        .externalInterface
    ],
    tags: ["module", "data"]
)
