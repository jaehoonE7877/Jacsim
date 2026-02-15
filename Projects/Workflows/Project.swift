import ProjectDescription
import ProjectDescriptionHelpers
import DependencyPlugin

let project = Project.makeModule(
    name: "Workflows",
    swiftLanguageVersion: .v6,
    targets: [.unitTest, .staticFramework],
    internalDependencies: [
        .Modules.shared,
        .domain,
        .ports
    ],
    tags: ["module", "workflows"]
)
