import ProjectDescription
import ProjectDescriptionHelpers
import DependencyPlugin

let project = Project.makeModule(
    name: "DesignSystem",
    swiftLanguageVersion: .v6,
    targets: [.staticFramework],
    internalDependencies: [
        .Modules.shared
    ],
    hasResources: true,
    tags: ["module", "design-system"]
)
