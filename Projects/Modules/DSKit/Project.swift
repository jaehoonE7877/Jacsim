import ProjectDescription
import ProjectDescriptionHelpers
import DependencyPlugin

let project = Project.makeFrameworkProject(
    name: "DesignSystem",
    swiftLanguageVersion: .v6,
    internalDependencies: [
        .Modules.shared
    ],
    hasResources: true,
    includeTests: false,
    tags: ["module", "design-system"]
)
