import ProjectDescription
import ProjectDescriptionHelpers
import DependencyPlugin

let project = Project.makeModule(
    name: "DSKit",
    swiftLanguageVersion: .v6,
    targets: [.staticFramework],
    internalDependencies: [
        .Modules.core
    ],
    hasResources: true,
    tags: ["module", "design-system"]
)
